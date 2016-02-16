class JxcPurchaseReturnsBill < JxcBaseModel
  ##  采购退货单
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  include Mongoid::Multitenancy::Document

  tenant(:client)

  field :bill_no, type: String            #单据编号
  field :customize_bill_no, type: String  #自定义单据编号
  field :collection_date, type: DateTime  #收款日期
  field :returns_date, type: DateTime     #退货日期
  field :current_collection, type: BigDecimal  #本次收款
  field :remark, type: String             #备注

  field :total_amount, type: BigDecimal        #合计金额
  field :discount, type: Integer, default:100          #整单折扣
  field :discount_amount, type: BigDecimal, default:0.00     #整单优惠
  field :collection_amount, type: BigDecimal   #应收金额
  field :bill_status, type: String, default: '0'        #单据状态( -1:已作废 | 0:已创建 | 1:已审核 | 2:已红冲 )

  belongs_to :supplier, class_name:'JxcContactsUnit',foreign_key: :supplier_id  #供应商
  belongs_to :jxc_storage, foreign_key: :storage_id        #退货仓库
  # belongs_to :jxc_account, foreign_key: :account_id        #收款账户
  has_and_belongs_to_many :handler, class_name:'User', foreign_key: :handler_id   #经手人
  has_and_belongs_to_many :bill_maker, class_name:'User', foreign_key: :maker_id    #制单人

  has_many :jxc_bill_details  #单据商品明细

  #生成单据编号
  def generate_bill_no
    random = ''
    6.times.each{
      random += rand(9).to_s
    }
    'CGTHD'+'-'+Time.now.strftime('%Y%m%d')+'-'+Time.now.strftime('%H%M%S')+'-'+random
  end

  #计算单据应收金额
  def calculate_bill_amount(total_amount,total_discount)
    bill_amount = (total_amount.to_d - total_discount.to_d).round(2)  #单据金额 = 总金额 - 优惠金额
  end

  ##单据操作

  #审核
  def audit(current_user)
    #结果集
    result = {}
    result[:flag] = 0

    #如果单据状态为已创建，则可继续审核
    if self.bill_status == BillStatus_Create
      #单据商品详情
      billDetailsArray = JxcBillDetail.where(:purchase_returns_bill_id => self.id)
      #仓库
      store = self.jxc_storage
      #整单折扣
      discount = self.discount

      #库存更新数组
      updateInventoryArray = []
      #库存变更日志数组
      storageChangeLogArray = []

      if billDetailsArray.present?
        billDetailsArray.each do |billDetail|
          #仓库&商品 明细
          begin
            store_product_detail = JxcStorageProductDetail.find_by(:jxc_storage => store,:resource_product_id => billDetail.resource_product_id )
          rescue
            store_product_detail = nil
          end

          if store_product_detail.present?
            previous_count = store_product_detail.count #变更前库存
            later_count = previous_count - billDetail.count #变更后库存

            if later_count< 0
              result[:msg] = billDetail.product.title.inspect+'库存数量不足，并且系统不允许负库存，请尝试用其他仓库出库!'
              return result
            else
              store_product_detail.amount = store_product_detail.calcInventoryAmount(store_product_detail.cost_price,later_count)
              store_product_detail.count = later_count

              updateInventoryArray << store_product_detail

              #记录库存变更日志
              bill_price = (billDetail.price * (discount.to_d / 100)).round(2)
              storageChangeLog = newInventoryChangeLog(self,billDetail,store,previous_count,later_count,bill_price,OperationType_StockOut,BillType_PurchaseReturns,BillStatus_Audit)
              storageChangeLogArray << storageChangeLog
            end
          else
            result[:msg] = billDetail.product.title.inspect+'库存中不存在，并且系统不允许负库存，请尝试用其他仓库出库!'
            return result
          end
        end
      end

      updateInventoryArray.each do |updateInfo|
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
      result[:msg] = '单据当前状态无法审核[不是刚创建的单据]!'
    end

    return result
  end

  #红冲
  def strike_a_balance(current_user)
    #结果集
    result = {}
    result[:flag] = 0

    if self.bill_status == BillStatus_Audit
      #单据商品详情
      billDetailsArray = JxcBillDetail.where(purchase_returns_bill_id: self.id)
      #仓库
      store = self.jxc_storage
      #整单折扣
      discount = self.discount

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

            bill_price = (billDetail.price * (discount.to_d / 100)).round(2)
            inventoryChangeLog(self,billDetail,store,previous_count,after_count,bill_price,OperationType_StrikeBalance,BillType_PurchaseReturns,BillStatus_StrikeBalance)
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
      result[:msg] = '单据当前状态无法红冲[不是已审核的单据]!'
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
      result[:msg] = '单据当前状态无法作废[不是刚创建的单据]!'
    end

    return result
  end
end
