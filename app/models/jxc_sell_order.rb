class JxcSellOrder
  ##  进销存 销售订单
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic

  field :order_no, type: String             #订单编号
  field :customize_order_no, type: String   #自定义订单编号
  field :consign_goods_date, type: DateTime #发货日期
  field :order_date, type: DateTime         #订单日期
  field :receivable_deposit, type: BigDecimal    #预收定金
  field :remark, type: String               #备注

  field :total_amount, type: BigDecimal                    #合计金额
  field :discount, type: Integer, default: 100        #整单折扣
  field :discount_amount, type: BigDecimal, default: 0.00        #整单优惠
  field :receivable_amount, type: BigDecimal      #应收金额
  field :bill_status, type: String, default: '0'  #单据状态 ( -1:已作废 | 0:已创建 | 1:已审核 | 2:已红冲 )

  belongs_to :consumer, class_name:'JxcContactsUnit', foreign_key: :consumer_id  #客户
  belongs_to :jxc_storage, foreign_key: :storage_id   #出货仓库
  # belongs_to :handler, class_name:'Staff', foreign_key: :handler_id   #经手人
  # belongs_to :jxc_account, foreign_key: :account_id        #收款账户
  belongs_to :bill_maker, class_name:'User', foreign_key: :maker_id    #制单人

  has_many :jxc_bill_details  #单据商品明细


  #生成销售订单编号
  def generate_bill_no
    random = ''
    6.times.each{
      random += rand(9).to_s
    }
    'XSDD'+'-'+Time.now.strftime('%Y%m%d')+'-'+Time.now.strftime('%H%M%S')+'-'+random
  end

  #计算单据金额
  def calculate_bill_amount(total_amount,total_discount)
    bill_amount = (total_amount.to_d - total_discount.to_d).round(2)  #单据金额 = 总金额 ×  折扣 - 优惠金额
  end

  #审核
  def audit
    #审核结果集
    result = {}
    result[:flag] = 0

    if self.bill_status == '0'
      #更新单据状态
      self.bill_status = '1'
      self.update

      #返回审核结果
      result[:flag] = 1
      result[:msg] = '单据已成功审核。'
    else
      result[:msg] = '单据当前状态无法审核[不是刚创建的单据]。'
    end

    return result
  end

  #红冲
  def strike_a_balance
    #红冲结果集
    result = {}
    result[:flag] = 0

    if self.bill_status == '1'
      #更新单据状态
      self.bill_status = '2'
      self.update

      #返回红冲结果
      result[:flag] = 1
      result[:msg] = '单据已成功红冲。'
    else
      result[:msg] = '单据当前状态无法红冲[不是已审核的单据]。'
    end

    return result
  end

  #作废
  def bill_invalid
    #作废结果集
    result = {}
    result[:flag] = 0

    if self.bill_status == '0'
      #更新单据状态
      self.bill_status = '-1'
      self.update

      #返回审核结果
      result[:flag] = 1
      result[:msg] = '单据已成功作废。'
    else
      result[:msg] = '单据当前状态无法作废[不是刚创建的单据]。'
    end

    return result
  end

end
