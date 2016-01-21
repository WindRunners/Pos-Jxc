class JxcStockAssignBill
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
  # belongs_to :handler, class_name:'Staff'  #经手人
  belongs_to :bill_maker, class_name:'User' #制单人

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
    if self.bill_status == '0'
      #单据商品详情
      billDetailArray = JxcTransferBillDetail.includes(:product).where(stock_assign_bill_id: self.id)
      #总库
      out_store = self.assign_out_stock[0]
      #要货仓库
      in_store = self.assign_in_stock[0]

      ##调出操作

      #总库 库存更新数组
      storageUpdateArray = []
      #总库 库存日志变更数组
      storageChangeLogArray = []

      if billDetailArray.present?
        billDetailArray.each do |billDetail|

          #总库 库存明细
          begin
            out_store_product_detail = JxcStorageProductDetail.find_by(:jxc_storage => out_store,:product => billDetail.product)
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
              storageChangeLog = JxcStorageJournal.new

              storageChangeLog.jxc_storage = out_store    #仓库
              storageChangeLog.product = out_store_product_detail.product   #商品
              storageChangeLog.staff = self.handler #经手人

              storageChangeLog.previous_count = previous_count   #库存变更前存量
              storageChangeLog.after_count = after_count   #库存变更后存量
              storageChangeLog.count = -billDetail.count #单据明细数量
              storageChangeLog.price = out_store_product_detail.cost_price
              storageChangeLog.amount = -(out_store_product_detail.cost_price.to_d * billDetail.count).round(2)
              storageChangeLog.op_type = '1'  #操作类型 <出库>
              storageChangeLog.jxc_stock_assign_bill = self  #库存变更依据的 单据
              storageChangeLog.bill_no = self.bill_no #单据编号
              storageChangeLog.bill_type = 'stock_assign'
              storageChangeLog.bill_status = '1'
              storageChangeLog.bill_create_date = self.created_at.strftime('%Y/%m/%d')

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
            in_store_product_detail = JxcStorageProductDetail.find_by(:jxc_storage => in_store,:product => billDetail.product)
          rescue
            in_store_product_detail = nil
          end

          #总库库存明细
          begin
            origin_detail = JxcStorageProductDetail.find_by(:jxc_storage => out_store,:product => billDetail.product)
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
            in_store_product_detail.product = billDetail.product
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
          storageJournal = JxcStorageJournal.new

          storageJournal.product = billDetail.product   #商品
          storageJournal.jxc_storage = in_store    #仓库
          storageJournal.staff = self.handler  #经手人

          storageJournal.previous_count = previous_count   #库存变更前存量
          storageJournal.after_count = after_count   #库存变更后存量
          storageJournal.count = billDetail.count #单据明细数量
          storageJournal.price = in_store_product_detail.cost_price
          storageJournal.amount = in_store_product_detail.cost_price.to_d * billDetail.count
          storageJournal.op_type = '0'  #操作类型 <入库>
          storageJournal.jxc_stock_assign_bill = self  #库存变更依据的 单据
          storageJournal.bill_no = self.bill_no #单据编号
          storageJournal.bill_type = 'stock_assign'
          storageJournal.bill_status = '1'
          storageJournal.bill_create_date = self.created_at.strftime('%Y/%m/%d')

          storageJournal.save
        end
      end

      #生成产品溯源子码
      generate_trace_sub_code

      #更新单据状态
      self.bill_status = '1'
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

    if self.bill_status == '1'
      #单据商品详情
      billDetailArray = JxcTransferBillDetail.includes(:product).where(stock_assign_bill_id: self.id)
      #总库
      out_store = self.assign_out_stock[0]
      #要货仓库
      in_store = self.assign_in_stock[0]

      if billDetailArray.present?
        billDetailArray.each do |billDetail|
          ## 要货仓库红冲

          #要货仓库 库存明细
          begin
            in_store_product_detail = JxcStorageProductDetail.find_by(:jxc_storage => in_store,:product => billDetail.product)
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
            storageJournal = JxcStorageJournal.new

            storageJournal.product = billDetail.product   #商品
            storageJournal.jxc_storage = in_store    #仓库
            storageJournal.staff = self.handler  #仓库商品变更 创建者<单据红冲者>

            storageJournal.previous_count = previous_count   #库存变更前存量
            storageJournal.after_count = after_count   #库存变更后存量
            storageJournal.count = -billDetail.count #单据明细数量
            storageJournal.price = in_store_product_detail.cost_price
            storageJournal.amount = -in_store_product_detail.cost_price * billDetail.count
            storageJournal.op_type = '4'  #操作类型 <红冲>
            storageJournal.jxc_stock_assign_bill = self  #库存变更依据的 单据
            storageJournal.bill_no = self.bill_no #库存变更依据的 单据编号
            storageJournal.bill_type = 'stock_assign'
            storageJournal.bill_status = '2'
            storageJournal.bill_create_date = self.created_at.strftime('%Y/%m/%d')

            storageJournal.save
          end


          ## 总库红冲

          #总库库 库存明细
          #仓库&商品 明细
          begin
            out_store_product_detail = JxcStorageProductDetail.find_by(:jxc_storage => out_store,:product => billDetail.product)
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
            storageJournal = JxcStorageJournal.new

            storageJournal.product = billDetail.product   #商品
            storageJournal.jxc_storage = out_store    #仓库
            storageJournal.staff = self.handler  #经手人

            storageJournal.previous_count = previous_count   #库存变更前存量
            storageJournal.after_count = after_count   #库存变更后存量
            storageJournal.count = billDetail.count #单据明细数量
            storageJournal.price = out_store_product_detail.cost_price
            storageJournal.amount = out_store_product_detail.cost_price * billDetail.count
            storageJournal.op_type = '4'  #操作类型 <红冲>
            storageJournal.jxc_stock_assign_bill = self  #库存变更依据的 单据
            storageJournal.bill_no = self.bill_no #库存变更依据的 单据编号
            storageJournal.bill_type = 'stock_assign'
            storageJournal.bill_status = '2'
            storageJournal.bill_create_date = self.created_at.strftime('%Y/%m/%d')

            storageJournal.save
          end
        end
      end

      #删除审核时生成的溯源子码
      destroy_trace_sub_code

      #更新单据状态
      self.bill_status = '2'  #<红冲>
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

    if self.bill_status == '0'
      self.bill_status = '-1'
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
      store = billDetail.assign_out_stock[0]
      product = billDetail.product
      assign_count = billDetail.package_count.to_i

      @root_trace_array = Traceability.where(:jxc_storage => store, :product => product, :codetype => 0,:generateSubCodeFlag => 0).sort(_id:1).limit(assign_count)

      @root_trace_array.each do |root_trace|

        sequence = 0  #子码序号

        root_trace.subCodeCount.times do

          #根据母码及要货单明细生成子码
          @subTraceObj = Traceability.new
          @subTraceObj.codetype = 1
          @subTraceObj.parent = root_trace
          @subTraceObj.jxc_transfer_bill_detail = billDetail
          @subTraceObj.product = billDetail.product
          @subTraceObj.jxc_storage = billDetail.assign_in_stock[0]

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

end
