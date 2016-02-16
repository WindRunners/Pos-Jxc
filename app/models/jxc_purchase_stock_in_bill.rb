class JxcPurchaseStockInBill < JxcBaseModel
  ## 采购入库单
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  include Mongoid::Multitenancy::Document

  tenant(:client)

  field :bill_no, type: String            #单据编号
  field :customize_bill_no, type: String  #自定义单据编号
  field :payment_date, type: DateTime         #付款日期
  field :stock_in_date, type: DateTime        #入库日期
  field :current_payment, type: BigDecimal     #本次付款
  field :remark, type: String   #备注
  field :total_amount, type: BigDecimal   #合计金额
  field :discount, type: Integer, default:100   #整单折扣
  field :discount_amount, type: BigDecimal, default:0.00    #整单优惠
  field :payable_amount, type: BigDecimal   #应付金额
  field :bill_status, type: String, default: '0'    #单据状态 ( -1:已作废 | 0:已创建 | 1:已审核 | 2:已红冲 )

  belongs_to :supplier, class_name:'JxcContactsUnit', foreign_key: :supplier_id #供应商
  belongs_to :jxc_storage, foreign_key: :storage_id  #入货仓库
  # belongs_to :jxc_account, foreign_key: :account_id  #付款账户
  has_and_belongs_to_many :handler, class_name:'User', foreign_key: :handler_id #经手人
  has_and_belongs_to_many :bill_maker, class_name:'User', foreign_key: :maker_id #制单人

  has_many :jxc_bill_details  #单据商品明细

  #生成采购入库单编号
  def generate_bill_no
    random = ''
    6.times.each{
      random += rand(9).to_s
    }
    'CGRKD'+'-'+Time.now.strftime('%Y%m%d')+'-'+Time.now.strftime('%H%M%S')+'-'+random
  end

  #计算单据应付金额
  def calculate_bill_amount(total_amount,total_discount)
    bill_amount = (total_amount.to_d - total_discount.to_d).round(2)  #单据金额 = 总金额 - 优惠金额
  end


  ## 单据操作

  # 审核
  def audit(current_user)
    #审核结果集
    result = {}
    result[:flag] = 0

    if self.bill_status == BillStatus_Create
      #单据商品详情
      billDetailsArray = JxcBillDetail.where(purchase_in_bill_id: self.id)
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
            previous_amount = store_product_detail.amount #更新前 库存总额

            #更新后库存
            after_count = previous_count + billDetail.count
            #更新后的库存总额 （ 库存金额 = 更新前库存金额 + 采购单价 × 采购数量 × 折扣 ）
            after_amount = (previous_amount + (billDetail.price * billDetail.count * (discount.to_d / 100) )).round(2)
            #重新计算 成本价 （ 更新后成本价 = 更新后库存金额 / 更新后库存总量 ）
            after_cost_price = store_product_detail.calcCostPrice(after_amount,after_count)

            store_product_detail.count = after_count
            store_product_detail.cost_price = after_cost_price
            store_product_detail.amount = after_amount

            store_product_detail.retail_price = billDetail.retail_price   #零售价
            store_product_detail.pack_spec = billDetail.pack_spec   #装箱规格
            store_product_detail.classifyProductsByGrossProfit  #根据商品利润对商品分级

            store_product_detail.update
          else
            #如果不存在，则添加
            store_product_detail = JxcStorageProductDetail.new

            store_product_detail.resource_product_id = billDetail.resource_product_id
            store_product_detail.mobile_category_id = billDetail.product.mobile_category_id
            store_product_detail.jxc_storage = billDetail.jxc_storage
            store_product_detail.unit = billDetail.unit     #单位
            store_product_detail.count = billDetail.count   #数量
            store_product_detail.cost_price = (billDetail.price * (discount.to_d / 100)).round(2)    #成本价
            store_product_detail.amount = (store_product_detail.cost_price.to_d * store_product_detail.count.to_d).round(2)    #库存金额

            store_product_detail.retail_price = billDetail.retail_price #零售价
            store_product_detail.pack_spec = billDetail.pack_spec #装箱规格
            store_product_detail.classifyProductsByGrossProfit

            store_product_detail.save

            #更新前库存
            previous_count = 0
            #更新后库存
            after_count = previous_count+billDetail.count
          end

          #仓库商品明细变更后，记录变更日志
          cost_price = (billDetail.price * (discount.to_d / 100)).round(2) #成本价
          inventoryChangeLog(self,billDetail,store,previous_count,after_count,cost_price,OperationType_StockIn,BillType_PurchaseStockIn,BillStatus_Audit)
        end
      end

      #生成产品溯源条码
      generate_trace_root_code

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

  # 冲账
  def strike_a_balance(current_user)
    #审核结果集
    result = {}
    result[:flag] = 0

    if self.bill_status == BillStatus_Audit
      #单据商品详情
      billDetailsArray = JxcBillDetail.where(purchase_in_bill_id: self.id)
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
            previous_amount = store_product_detail.amount #更新前库存金额

            after_count = previous_count - billDetail.count #更新后库存
            after_amount = (previous_amount - billDetail.amount).round(2)
            after_cost_price = store_product_detail.calcCostPrice(after_amount,after_count)

            store_product_detail.cost_price = after_cost_price
            store_product_detail.count = after_count
            store_product_detail.amount = after_amount

            store_product_detail.update

            #仓库商品明细变更后，记录变更日志
            cost_price = (billDetail.price * (discount.to_d / 100)).round(2)
            inventoryChangeLog(self,billDetail,store,previous_count,after_count,cost_price,OperationType_StrikeBalance,BillType_PurchaseStockIn,BillStatus_StrikeBalance)
          end
        end
      end

      #红冲后，之前生成的产品溯源条码一并删除
      destroy_trace_root_code

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

  # 作废
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
      result[:msg] = '单据当前状态无法作废[不是刚创建的单据]!'
    end

    return result
  end


  #生成产品溯源条码
  def generate_trace_root_code
    billDetailArray = JxcBillDetail.where(:purchase_in_bill_id => self.id)  #采购单详情

    billDetailArray.each do |billDetail|
      #溯源条码 母码个数（采购商品件数）
      rootCodeCount = billDetail.package_count
      if rootCodeCount.present?
        rootCodeCount.times do
          @traceObj = Traceability.new

          @traceObj.barcode = @traceObj.generate_root_barcode #溯源条码
          @traceObj.codetype = 0  #母码
          @traceObj.jxc_bill_detail = billDetail  #采购入库 明细
          @traceObj.subCodeCount = billDetail.pack_spec #溯源条码 子码个数 ( 商品装箱规格 )
          @traceObj.resource_product_id = billDetail.resource_product_id  #溯源的商品
          @traceObj.jxc_storage = billDetail.jxc_storage  #采购入库仓库

          @traceObj.save
        end
      end
    end
  end

  #删除生成的产品溯源条码
  def destroy_trace_root_code
    billDetailArray = JxcBillDetail.includes(:traceabilities).where(:purchase_in_bill_id => self.id)
    billDetailArray.each do |billDetail|
      billDetail.traceabilities.destroy
    end
  end

end

