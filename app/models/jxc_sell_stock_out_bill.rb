class JxcSellStockOutBill < JxcBaseModel
  ## 进销存 销售出库单
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  include Mongoid::Multitenancy::Document

  tenant(:client)

  field :bill_no, type: String            #单据编号
  field :customize_bill_no, type: String  #自定义单据编号
  field :collection_date, type: DateTime  #收款日期
  field :stock_out_date, type: DateTime   #出库日期
  field :current_collection, type: BigDecimal, default: 0.00  #本次收款
  field :remark, type: String             #备注

  field :total_amount, type: BigDecimal         #合计金额
  field :discount, type: Integer, default: 100            #整单折扣
  field :discount_amount, type: BigDecimal, default: 0.00 #整单优惠
  field :receivable_amount, type: BigDecimal              #应收金额
  field :bill_status, type: String, default: '0'          #单据状态( -1:已作废 | 0:已创建 | 1:已审核 | 2:已红冲 )

  belongs_to :consumer, class_name:'JxcContactsUnit', foreign_key: :consumer_id #客户
  belongs_to :jxc_storage, foreign_key: :storage_id  #出货仓库
  # belongs_to :jxc_account, foreign_key: :account_id  #收款账户
  has_and_belongs_to_many :handler, class_name:'User', foreign_key: :handler_id   #经手人
  has_and_belongs_to_many :bill_maker, class_name:'User', foreign_key: :maker_id  #制单人

  has_many :jxc_bill_details  #单据商品明细
  belongs_to :order # 销售订单

  #生成销售出库单编号
  def generate_bill_no
    random = ''
    6.times.each{
      random += rand(9).to_s
    }
    'XSCKD'+'-'+Time.now.strftime('%Y%m%d')+'-'+Time.now.strftime('%H%M%S')+'-'+random
  end

  #计算单据金额
  def calculate_bill_amount(total_amount,total_discount)
    bill_amount = (total_amount.to_d - total_discount.to_d).round(2)  #单据金额 = 总金额 ×  折扣 - 优惠金额
  end

  #审核
  def audit(current_user)
    #结果集
    result = {}
    result[:flag] = 0

    #如果单据状态为： 已创建
    if self.bill_status == BillStatus_Create
      #单据商品详情
      billDetailsArray = JxcBillDetail.where(:sell_out_bill_id => self.id)
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
            previous_count = store_product_detail.count
            later_count = previous_count - billDetail.count
            if later_count < 0
              result[:msg] = billDetail.product.title.inspect+'库存数量不足，并且系统不允许负库存，请尝试用其他仓库出库!'
              return result
            else
              store_product_detail.count = later_count
              store_product_detail.amount = store_product_detail.calcInventoryAmount(store_product_detail.cost_price,later_count)

              updateStorageArray << store_product_detail

              #记录仓库明细变更日志
              storageChangeLog = newInventoryChangeLog(self,billDetail,store,previous_count,later_count,store_product_detail.cost_price,OperationType_StockOut,BillType_SellStockOut,BillStatus_Audit)
              storageChangeLogArray << storageChangeLog

              #判断是否触发库存预警
              inventory_warning_judge(store,store_product_detail)

            end
          else
            result[:msg] = billDetail.product.title.inspect+'库存中不存在，并且系统不允许负库存，请尝试用其他仓库出库!'
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
      result[:msg] = '单据当前状态无法审核[不是刚创建的单据]'
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
      billDetailsArray = JxcBillDetail.where(sell_out_bill_id: self.id)
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
            inventoryChangeLog(self,billDetail,store,previous_count,after_count,store_product_detail.cost_price,OperationType_StockIn,BillType_SellStockOut,BillStatus_StrikeBalance)
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
      result[:msg] = '单据当前状态无法作废[不是刚创建的单据]。'
    end

    return result
  end

  #POS生成销售出库单(当前用户，订单ID，门店，总金额，实收金额，销售商品json[商品ID、商品单位、商品零售价、商品数量])
  def self.generate_sell_out_bill(current_user,order_id,retail_store,total_amount,receivable_amount,bill_detail_array_json)
    #结果集
    result = {}
    result[:flag] = 0

    store = retail_store.jxc_storage #门店对应的仓库信息
    retail_consumer = JxcContactsUnit.find_by(:unit_name => '零售客户') #零售客户
    # financial_account

    begin
      #录入销售出库单
      @sell_out_bill = self.new
      @sell_out_bill.bill_no = @sell_out_bill.generate_bill_no
      @sell_out_bill.jxc_storage = store
      @sell_out_bill.consumer = retail_consumer
      @sell_out_bill.collection_date = Time.now #收款日期
      @sell_out_bill.stock_out_date = Time.now  #出库日期
      @sell_out_bill.handler << current_user  #经手人
      @sell_out_bill.bill_maker << current_user #制单人
      @sell_out_bill.total_amount = total_amount  #总金额
      @sell_out_bill.receivable_amount = receivable_amount  #实收金额
      @sell_out_bill.discount_amount = total_amount.to_d - receivable_amount.to_d #优惠

      @sell_out_bill['order_id'] = order_id

      @sell_out_bill.save

      #单据明细
      bill_detail_array = JSON.parse(bill_detail_array_json)
      Rails.logger.info "销售出库单:#{bill_detail_array}"
      bill_detail_array.each do |bill_detail|

        @temp_bill_detail = JxcBillDetail.new

        @temp_bill_detail.resource_product_id = bill_detail['product_id']
        @temp_bill_detail.unit = bill_detail['unit']
        @temp_bill_detail.price = bill_detail['price']
        @temp_bill_detail.count = bill_detail['count']
        @temp_bill_detail.amount = bill_detail['price'].to_d * bill_detail['count'].to_d

        @temp_bill_detail.jxc_storage = store
        @temp_bill_detail.jxc_contacts_unit = retail_consumer
        @temp_bill_detail.jxc_sell_stock_out_bill = @sell_out_bill

        @temp_bill_detail.save!
      end

    rescue Exception => e
      result[:msg] = "销售出库单生成失败，请重试#{e.message}"
      return result
    end

    #审核单据
    audit_result = @sell_out_bill.audit(current_user)

    #返回结果集
    if audit_result[:flag] == 1
      result[:flag] = 1
      result[:msg] = '销售出库单成功录入，且库存已成功转化。'
    else
      result[:flag] = 0
      result[:msg] = audit_result[:msg]
    end

    result
  end

end
