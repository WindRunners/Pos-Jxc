class JxcStockReduceBill < JxcBaseModel
  ## 进销存 报损单
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic

  field :bill_no, type: String            #单据编号
  field :customize_bill_no, type: String  #自定义单据编号
  field :reduce_date, type: DateTime      #报损日期
  field :remark, type: String             #备注

  field :bill_status, type: String, default: '0'    #单据状态 ( -1:已作废 | 0:已创建 | 1:已审核 | 2:已红冲 )

  belongs_to :jxc_storage, foreign_key: :storage_id  #报损仓库
  has_and_belongs_to_many :handler, class_name:'User', foreign_key: :handler_id  #经手人
  has_and_belongs_to_many :bill_maker, class_name:'User', foreign_key: :maker_id  #制单人

  belongs_to :jxc_stock_count_bill  #盘点单

  has_many :jxc_bill_details  #单据商品明细

  #生成单据编号
  def generate_bill_no
    random = ''
    6.times.each{
      random += rand(9).to_s
    }
    'BSD'+'-'+Time.now.strftime('%Y%m%d')+'-'+Time.now.strftime('%H%M%S')+'-'+random
  end


  #审核
  def audit(current_user)
    #结果集
    result = {}
    result[:flag] = 0

    #如果单据状态为： 已创建
    if self.bill_status == BillStatus_Create

      #单据商品详情
      billDetailsArray = JxcBillDetail.where(stock_reduce_bill_id: self.id)
      #仓库
      store = self.jxc_storage

      #库存更新数组
      updateStorageArray = []
      #库存变更日志数组
      storageChangeLogArray = []

      if billDetailsArray.present?
        billDetailsArray.each do |billDetail|
          #仓库&商品 明细
          begin
            store_product_detail = JxcStorageProductDetail.find_by(:jxc_storage => store,:resource_product_id => billDetail.resource_product_id)
          rescue
            store_product_detail = nil
          end

          if store_product_detail.present?
            previous_count = store_product_detail.count #变更前库存
            after_count = previous_count - billDetail.count #变更后库存

            if after_count < 0
              result[:msg] = billDetail.product.title.inspect+'库存数量不足，并且系统不允许负库存，请重新核对报损数量!'
              return result
            else

              #报损后，库存数量
              store_product_detail.count = after_count
              #报损后，库存金额
              store_product_detail.amount = store_product_detail.calcInventoryAmount(store_product_detail.cost_price,after_count)

              updateStorageArray << store_product_detail

              #记录库存变更日志
              storageChangeLog = newInventoryChangeLog(self,billDetail,store,previous_count,after_count,store_product_detail.cost_price,OperationType_Reduce,BillType_StockReduce,BillStatus_Audit)
              storageChangeLogArray << storageChangeLog
            end
          else
            result[:msg] = billDetail.product.title.inspect+'库存中不存在，并且系统不允许负库存，请重新核对报损商品!'
            return result
          end
        end
      end

      updateStorageArray.each do |updateInfo|
        updateInfo.update
      end

      storageChangeLogArray.each do |changeLog|
        changeLog.save
      end

      #更细单据状态
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
    #结果集
    result = {}
    result[:flag] = 0

    if self.bill_status == BillStatus_Audit

      #单据商品详情
      billDetailsArray = JxcBillDetail.where(stock_reduce_bill_id: self.id)
      #仓库
      store = self.jxc_storage

      if billDetailsArray.present?
        billDetailsArray.each do |billDetail|

          #仓库&商品 明细
          begin
            store_product_detail = JxcStorageProductDetail.find_by(:jxc_storage => store,:resource_product_id => billDetail.resource_product_id)
          rescue
            store_product_detail = nil
          end

          #如果 仓库中存在商品 ，更新存量
          if store_product_detail.present?
            previous_count = store_product_detail.count #更新前库存
            after_count = previous_count + billDetail.count #更新后库存
            store_product_detail.count = after_count
            store_product_detail.amount = store_product_detail.calcInventoryAmount(store_product_detail.cost_price,after_count)
            store_product_detail.update

            #仓库商品明细变更后，记录变更日志
            inventoryChangeLog(self,billDetail,store,previous_count,after_count,store_product_detail.cost_price,OperationType_StrikeBalance,BillType_StockReduce,BillStatus_StrikeBalance)
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
    #操作结果集
    result = {}
    result[:flag] = 0

    if self.bill_status == BillStatus_Create
      #更新单据状态
      self.bill_status = BillStatus_Invalid
      self.update

      #返回审核结果
      result[:flag] = 1
      result[:msg] = '单据已成功作废。'
    else
      result[:msg] = '单据当前状态无法作废!'
    end

    return result
  end
end
