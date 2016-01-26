class JxcPurchaseOrder < JxcBaseModel
  ## 采购订单
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic

  field :order_no, type: String             #订单编号
  field :customize_order_no, type: String   #自定义订单编号
  field :receive_goods_date, type: DateTime #到货日期
  field :order_date, type: DateTime         #订单日期
  field :down_payment, type: BigDecimal, default: 0.00     #预付定金
  field :remark, type: String               #备注
  field :total_amount, type: BigDecimal     #合计金额
  field :discount, type: Integer, default: 100             #整单折扣
  field :discount_amount, type: BigDecimal, default: 0.00  #整单优惠
  field :payable_amount, type: BigDecimal         #应付金额
  field :bill_status, type: String, default: '0'  #单据状态 ( -1:已作废 | 0:已创建 | 1:已审核 | 2:已红冲 )

  belongs_to :supplier, class_name:'JxcContactsUnit', foreign_key: :supplier_id   #供应商
  belongs_to :jxc_storage, foreign_key: :storage_id   #入货仓库
  has_and_belongs_to_many :handler, class_name:'User', foreign_key: :handler_id   #经手人
  # belongs_to :jxc_account, foreign_key: :account_id   #付款账户
  has_and_belongs_to_many :bill_maker, class_name:'User', foreign_key: :maker_id    #制单人

  has_many :jxc_bill_details #单据商品明细

  #生成订单编号
  def generate_order_no
    random = ''
    6.times.each{
      random += rand(9).to_s
    }
    'CGDD'+'-'+Time.now.strftime('%Y%m%d')+'-'+Time.now.strftime('%H%M%S')+'-'+random
  end

  #计算单据金额
  def calculate_bill_amount(total_amount,total_discount)
    bill_amount = (total_amount.to_d - total_discount.to_d).round(2)  #单据金额 = 总金额 - 优惠金额
  end

  #单据审核
  def audit
    #审核结果集
    result = {}
    result[:flag] = 0

    if self.bill_status == BillStatus_Create
      #更新单据状态
      self.bill_status = BillStatus_Audit
      self.update

      #返回审核结果
      result[:flag] = 1
      result[:msg] = '审核通过'
    else
      result[:msg] = '单据当前状态无法审核![不是刚创建的单据]'
    end

    return result
  end


  ## 单据 冲账
  def strike_a_balance
    #审核结果集
    result = {}
    result[:flag] = 0

    if self.bill_status == BillStatus_Audit
      #更新单据状态
      self.bill_status = BillStatus_StrikeBalance  #<红冲>
      self.update

      #审核结果返回
      result[:flag] = 1
      result[:msg] = '单据已红冲'
    else
      result[:msg] = '单据当前状态无法红冲![不是已审核的单据]'
    end

    return result
  end


  #单据作废
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
      result[:msg] = '单据当前状态无法作废![不是刚创建的单据]'
    end

    return result
  end
end
