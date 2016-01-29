class JxcStockAssignBill < JxcBaseModel
  ## 进销存 要货单
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic

  field :bill_no, type: String            #单据编号
  field :customize_bill_no, type: String  #自定义单据编号
  field :assign_date, type: Date          #要货日期
  field :remark, type: String             #备注

  field :bill_status, type: String, default: '0'        #单据状态 ( -1:已作废 | 0:已创建 | 1:已审核 | 2:已红冲 )

  has_and_belongs_to_many :assign_out_stock, class_name:'JxcStorage' #调出仓库
  has_and_belongs_to_many :assign_in_stock, class_name:'JxcStorage' #调入仓库
  has_and_belongs_to_many :handler, class_name:'User', foreign_key: :handler_id  #经手人
  has_and_belongs_to_many :bill_maker, class_name:'User', foreign_key: :maker_id #制单人

  has_many :jxc_transfer_bill_details    #要货单 商品明细
  has_many :jxc_storage_journals  #库存变更日志
  #生成单据编号
  def generate_bill_no
    random = ''
    6.times.each{
      random += rand(9).to_s
    }
    'YHD'+'-'+Time.now.strftime('%Y%m%d')+'-'+Time.now.strftime('%H%M%S')+'-'+random
  end

  #要货单审核
  def audit

    #结果集
    result = {}
    result[:flag] = 0

    #单据状态为 “已创建” 才可继续审核
    if self.bill_status == BillStatus_Create
      #单据商品详情
      billDetailArray = JxcTransferBillDetail.where(stock_assign_bill_id: self.id)
      #总库
      out_store = self.assign_out_stock
      #要货仓库
      in_store = self.assign_in_stock

      ##调出操作

      #总库 库存更新数组
      storageUpdateArray = []
      #总库 库存日志变更数组
      storageChangeLogArray = []

      if billDetailArray.present?
        billDetailArray.each do |billDetail|

          #总库 库存明细
          begin
            out_store_product_detail = JxcStorageProductDetail.find_by(:jxc_storage => out_store,:resource_product_id => billDetail.resource_product_id)
          rescue
            out_store_product_detail = nil
          end

          if out_store_product_detail.present?
            previous_count = out_store_product_detail.count #变更前库存
            after_count = previous_count - billDetail.count #变更后库存

            if after_count< 0
              result[:msg] = billDetail.product.title.inspect+'库存数量不足，并且系统不允许负库存，请尝试用其他仓库出库!'
              return result
            else
              #调出后，仓库库存
              out_store_product_detail.count = after_count
              out_store_product_detail.amount = out_store_product_detail.calcInventoryAmount(out_store_product_detail.cost_price,after_count)

              #记录库存变更日志
              storageChangeLog = newInventoryChangeLog(self,billDetail,out_store,previous_count,after_count,out_store_product_detail.cost_price,OperationType_StockOut,BillType_StockAssign,BillStatus_Audit)
              storageChangeLogArray << storageChangeLog
            end

          else
            result[:msg] = billDetail.product.title.inspect+' 库存中不存在，并且系统不允许负库存，请尝试用其他仓库出库!'
            return result
          end
          storageUpdateArray << out_store_product_detail
        end
      end

      storageUpdateArray.each do |updateInfo|
        updateInfo.update
      end

      storageChangeLogArray.each do |changeLog|
        changeLog.save
      end

      ##调入操作

      if billDetailArray.present?
        billDetailArray.each do |billDetail|
          #要货仓库库存明细
          begin
            in_store_product_detail = JxcStorageProductDetail.find_by(:jxc_storage => in_store,:resource_product_id => billDetail.resource_product_id)
          rescue
            in_store_product_detail = nil
          end

          #总库库存明细
          begin
            origin_detail = JxcStorageProductDetail.find_by(:jxc_storage => out_store,:resource_product_id => billDetail.resource_product_id)
          rescue
            origin_detail = nil
          end

          #如果 库存中存在商品，则更新存量
          if in_store_product_detail.present?
            previous_count = in_store_product_detail.count #更新前库存
            after_count = previous_count + billDetail.count #更新后库存

            in_store_product_detail.amount = in_store_product_detail.calcInventoryAmount(in_store_product_detail.cost_price,after_count)
            in_store_product_detail.count = after_count

            in_store_product_detail.update
          else
            #如果不存在，则添加
            in_store_product_detail = JxcStorageProductDetail.new

            in_store_product_detail.jxc_storage = in_store
            in_store_product_detail.resource_product_id = billDetail.resource_product_id
            in_store_product_detail.unit = billDetail.unit
            in_store_product_detail.count = billDetail.count
            in_store_product_detail.cost_price = origin_detail.present? ? origin_detail.cost_price : 0
            in_store_product_detail.amount = in_store_product_detail.calcInventoryAmount(in_store_product_detail.cost_price,billDetail.count)

            in_store_product_detail.save

            #更新前库存
            previous_count = 0
            #更新后库存
            after_count = billDetail.count
          end

          ##记录 要货仓库 库存变更日志
          inventoryChangeLog(self,billDetail,in_store,previous_count,after_count,in_store_product_detail.cost_price,OperationType_StockIn,BillType_StockAssign,BillStatus_Audit)
        end
      end

      #生成产品溯源子码
      generate_trace_sub_code

      #更新单据状态
      self.bill_status = BillStatus_Audit
      self.update

      #返回审核结果
      result[:flag] = 1
      result[:msg] = '审核通过'
    else
      result[:msg] = '单据当前状态无法审核!'
    end

    return result
  end


  #冲账
  def strike_a_balance

    #审核结果集
    result = {}
    result[:flag] = 0

    if self.bill_status == BillStatus_Audit
      #单据商品详情
      billDetailArray = JxcTransferBillDetail.where(stock_assign_bill_id: self.id)
      #总库
      out_store = self.assign_out_stock
      #要货仓库
      in_store = self.assign_in_stock

      if billDetailArray.present?
        billDetailArray.each do |billDetail|
          ## 要货仓库红冲

          #要货仓库 库存明细
          begin
            in_store_product_detail = JxcStorageProductDetail.find_by(:jxc_storage => in_store,:resource_product_id => billDetail.resource_product_id)
          rescue
            in_store_product_detail = nil
          end

          if in_store_product_detail.present?
            previous_count = in_store_product_detail.count #更新前库存
            after_count = previous_count - billDetail.count #更新后库存

            in_store_product_detail.count = after_count
            in_store_product_detail.amount = in_store_product_detail.calcInventoryAmount(in_store_product_detail.cost_price,after_count)
            in_store_product_detail.update

            #仓库商品明细变更后，记录变更日志
            inventoryChangeLog(self,billDetail,in_store,previous_count,after_count,in_store_product_detail.cost_price,OperationType_StrikeBalance,BillType_StockAssign,BillStatus_StrikeBalance)
          end


          ## 总库红冲

          #总库库 库存明细
          #仓库&商品 明细
          begin
            out_store_product_detail = JxcStorageProductDetail.find_by(:jxc_storage => out_store,:resource_product_id => billDetail.resource_product_id)
          rescue
            out_store_product_detail = nil
          end

          if out_store_product_detail.present?
            previous_count = out_store_product_detail.count #更新前库存
            after_count = previous_count + billDetail.count #更新后库存

            out_store_product_detail.count = after_count
            out_store_product_detail.amount = out_store_product_detail.calcInventoryAmount(out_store_product_detail.cost_price,after_count)
            out_store_product_detail.update

            #仓库商品明细变更后，记录变更日志
            inventoryChangeLog(self,billDetail,out_store,previous_count,after_count,out_store_product_detail.cost_price,OperationType_StrikeBalance,BillType_StockAssign,BillStatus_StrikeBalance)
          end
        end
      end

      #删除审核时生成的溯源子码
      destroy_trace_sub_code

      #更新单据状态
      self.bill_status = BillStatus_StrikeBalance  #<红冲>
      self.update

      #审核结果返回
      result[:flag] = 1
      result[:msg] = '单据已红冲'
    else
      result[:msg] = '单据当前状态无法红冲!'
    end

    return result
  end

  #作废
  def bill_invalid
    #处理结果
    result = {}

    if self.bill_status == BillStatus_Create
      self.bill_status = BillStatus_Invalid
      self.update
      result[:flag] = 1
      result[:msg] = '单据已作废'
    else
      result[:flag] = 0
      result[:msg] = '单据当前状态无法作废!'
    end

    return result
  end

  #根据要货单明细生成 产品溯源 子码
  def generate_trace_sub_code

    #要货单明细
    billDetailArray = JxcTransferBillDetail.where(:stock_assign_bill_id => self.id)

    billDetailArray.each do |billDetail|
      store = billDetail.assign_out_stock
      resource_product_id = billDetail.resource_product_id
      assign_count = billDetail.package_count.to_i

      @root_trace_array = Traceability.where(:jxc_storage => store, :resource_product_id => resource_product_id, :codetype => 0,:generateSubCodeFlag => 0).sort(_id:1).limit(assign_count)

      @root_trace_array.each do |root_trace|

        sequence = 0  #子码序号

        root_trace.subCodeCount.times do

          #根据母码及要货单明细生成子码
          @subTraceObj = Traceability.new
          @subTraceObj.codetype = 1
          @subTraceObj.parent = root_trace
          @subTraceObj.jxc_transfer_bill_detail = billDetail
          @subTraceObj.resource_product_id = billDetail.resource_product_id
          @subTraceObj.jxc_storage = billDetail.assign_in_stock

          if sequence < 10
            @subTraceObj.barcode = root_trace.barcode + '0' + sequence.inspect
            @subTraceObj.seqcode = root_trace.subCodeCount.inspect + '-' + '0' + sequence.inspect
          else
            @subTraceObj.barcode = root_trace.barcode + sequence.inspect
            @subTraceObj.seqcode = root_trace.subCodeCount.inspect + '-' + sequence.inspect
          end

          @subTraceObj.save

          sequence += 1
        end

        #生成过子码，更新母码的状态
        root_trace.generateSubCodeFlag = 1
        root_trace.jxc_transfer_bill_detail = billDetail
        root_trace.update
      end
    end
  end

  #单据红冲，删除之前生成的子码，并且重置将相关母码状态
  def destroy_trace_sub_code
    #要货单明细
    billDetailArray = JxcTransferBillDetail.where(:stock_assign_bill_id => self.id)

    billDetailArray.each do |billDetail|
      #删除子码
      billDetail.traceabilities.where(:codetype => 1).destroy

      #重置关联母码状态
      billDetail.traceabilities.where(:codetype => 0).each do |root_trace|
        root_trace.generateSubCodeFlag = 0
        root_trace.update
      end
    end
  end


  def assign_out_stock
    begin
      @assign_out_stock = JxcStorage.find(self.assign_out_stock_ids[0])
    rescue
      @assign_out_stock = nil
    end
    return @assign_out_stock
  end


  def assign_in_stock
    begin
      @assign_in_stock = JxcStorage.find(self.assign_in_stock_ids[0])
    rescue
      @assign_in_stock = nil
    end
    return @assign_in_stock
  end

end
