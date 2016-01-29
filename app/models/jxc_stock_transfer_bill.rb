class JxcStockTransferBill < JxcBaseModel
  ## 进销存  调拨单
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic

  field :bill_no, type: String            #单据编号
  field :customize_bill_no, type: String  #自定义单据编号
  field :transfer_date, type: Date        #调拨日期
  field :transfer_way, type: String       #调拨方式（ 0:同价调拨 | 1:变价调拨 ）
  field :remark, type: String             #备注

  field :bill_status, type: String, default: BillStatus_Create        #单据状态 ( -1:已作废 | 0:已创建 | 1:已审核 | 2:已红冲 )

  has_and_belongs_to_many :transfer_out_stock, class_name:'JxcStorage' #调出仓库
  has_and_belongs_to_many :transfer_in_stock, class_name:'JxcStorage' #调入仓库
  has_and_belongs_to_many :handler, class_name:'User'  #经手人
  has_and_belongs_to_many :bill_maker, class_name:'User' #制单人

  has_many :jxc_transfer_bill_details    #调拨单 商品明细

  #生成单据编号
  def generate_bill_no
    random = ''
    6.times.each{
      random += rand(9).to_s
    }
    'DBD'+'-'+Time.now.strftime('%Y%m%d')+'-'+Time.now.strftime('%H%M%S')+'-'+random
  end

  #审核
  def audit(current_user)

    #结果集
    result = {}
    result[:flag] = 0

    #如果单据状态为： 已创建
    if self.bill_status == BillStatus_Create
      #单据商品详情
      billDetailArray = JxcTransferBillDetail.where(stock_transfer_bill_id: self.id)
      #调出仓库
      out_store = self.transfer_out_stock[0]
      #调入仓库
      in_store = self.transfer_in_stock[0]

      ## 调出操作

      #调出仓库 库存更新数组
      storageUpdateArray = []
      #调出仓库 库存日志变更数组
      storageChangeLogArray = []

      if billDetailArray.present?
        billDetailArray.each do |billDetail|
          #库存 明细
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
              #调拨后，调出仓库库存
              out_store_product_detail.count = after_count
              #调拨后，调出仓库库存金额
              out_store_product_detail.amount = out_store_product_detail.calcInventoryAmount(out_store_product_detail.cost_price,after_count)


              #记录库存变更日志
              storageChangeLog = newInventoryChangeLog(self,billDetail,out_store,previous_count,after_count,out_store_product_detail.cost_price,OperationType_StockOut,BillType_StockTransfer,BillStatus_Audit)
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

      ## 调入操作

      if billDetailArray.present?
        billDetailArray.each do |billDetail|
          #库存 明细
          begin
            in_store_product_detail = JxcStorageProductDetail.find_by(:jxc_storage => in_store,:resource_product_id => billDetail.resource_product_id)
          rescue
            in_store_product_detail = nil
          end

          #如果 库存中存在商品，则更新存量
          if in_store_product_detail.present?
            previous_count = in_store_product_detail.count #更新前库存
            after_count = previous_count + billDetail.count #更新后库存

            #调拨后，库存金额 = 调拨前库存金额 + 调拨金额
            amount = in_store_product_detail.amount + billDetail.amount
            #调拨后，重新计算商品库存单价
            cost_price = (amount.to_d / after_count.to_d).round(2)

            in_store_product_detail.count = after_count
            in_store_product_detail.cost_price = cost_price
            in_store_product_detail.amount = amount

            in_store_product_detail.update
          else
            #如果不存在，则添加
            in_store_product_detail = JxcStorageProductDetail.new

            in_store_product_detail.jxc_storage = in_store
            in_store_product_detail.resource_product_id = billDetail.resource_product_id
            in_store_product_detail.mobile_category_id = billDetail.product.mobile_category_id
            in_store_product_detail.unit = billDetail.unit
            in_store_product_detail.count = billDetail.count
            in_store_product_detail.cost_price = billDetail.transfer_price
            in_store_product_detail.amount = billDetail.amount

            in_store_product_detail.save

            #更新前库存
            previous_count = 0
            #更新后库存
            after_count = billDetail.count
          end

          #记录 调入仓库 库存变更日志
          inventoryChangeLog(self,billDetail,in_store,previous_count,after_count,billDetail.transfer_price,OperationType_StockIn,BillType_StockTransfer,BillStatus_Audit)
        end
      end

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
  def strike_a_balance(current_user)
    #审核结果集
    result = {}
    result[:flag] = 0

    if self.bill_status == BillStatus_Audit
      #单据商品详情
      billDetailArray = JxcTransferBillDetail.where(stock_transfer_bill_id: self.id)
      #调出仓库
      out_store = self.transfer_out_stock[0]
      #调入仓库
      in_store = self.transfer_in_stock[0]

      if billDetailArray.present?
        billDetailArray.each do |billDetail|
          ## 调入仓库红冲

          #调入仓库 库存明细
          begin
            in_store_product_detail = JxcStorageProductDetail.find_by(:jxc_storage => in_store,:resource_product_id => billDetail.resource_product_id)
          rescue
            in_store_product_detail = nil
          end

          if in_store_product_detail.present?
            previous_count = in_store_product_detail.count #更新前库存
            after_count = previous_count - billDetail.count #更新后库存

            #红冲后，库存金额 = 原库存金额 - 调拨金额
            inventory_amount = in_store_product_detail.amount.to_d - billDetail.amount.to_d
            #红冲后，重新计算成本价
            cost_price = (inventory_amount.to_d / after_count.to_d).round(2)

            in_store_product_detail.cost_price = cost_price
            in_store_product_detail.count = after_count
            in_store_product_detail.amount = inventory_amount

            in_store_product_detail.update

            #仓库商品明细变更后，记录变更日志
            inventoryChangeLog(self,billDetail,in_store,previous_count,after_count,billDetail.transfer_price,OperationType_StrikeBalance,BillType_StockTransfer,BillStatus_StrikeBalance)
          end


          ## 调出仓库红冲

          #调出仓库 库存明细
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
            inventoryChangeLog(self,billDetail,out_store,previous_count,after_count,out_store_product_detail.cost_price,OperationType_StrikeBalance,BillType_StockTransfer,BillStatus_StrikeBalance)
          end
        end
      end

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
end
