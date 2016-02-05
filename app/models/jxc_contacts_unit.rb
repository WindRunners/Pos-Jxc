class JxcContactsUnit
  # 往来单位
  include Mongoid::Document
  include Mongoid::Timestamps

  # 基本信息
  field :unit_name, type: String  #单位名称
  field :unit_property, type: String  #单位性质（供应商：0 | 客户：1 ）
  field :unit_type, type: String  #单位类别
  field :spell_code, type: String   #拼音编码（首字母集）
  field :unit_address, type: String #单位地址
  field :unit_code, type: String  #单位编码
  field :data_1, type: String   #扩展属性1
  field :data_2, type: String   #扩展属性2
  field :data_3, type: String   #扩展属性3
  field :data_4, type: String   #扩展属性4

  # 首要联系人
  field :contact_name, type: String   #联系人
  field :contact_call, type: String   #联系电话
  field :contact_mobile, type: String #手机
  field :contact_fax, type: String    #传真
  field :contact_address, type: String  #所属地区
  field :contact_postcode, type: String #邮政编码
  field :contact_email, type:String     #电子邮箱

  # 附加信息
  field :legal_person, type: String  #单位法人代表
  field :registered_capital, type: Float #注册资金
  field :bank_info, type: String #开户银行
  field :bank_account, type: String #账号
  field :company_type, type: String #经济类型(外资 | 国营 | 私营 等)
  field :tax_number,  type: String #税号

  field :business_range, type: String  #业务范围
  field :consumer_overview, type: String #客户概况

  ## 收付款 信息
  field :start_receivable, type: Float #期初应收款
  field :start_payable, type: Float #期初应付款

  field :total_receivable, type: Float #累计应收款
  field :total_payable, type: Float #累计应付款

  field :receivable_credit, type: Float #应收信用额
  field :payable_credit, type: Float #应付信用额

  field :receive_deadline, type: Integer #收款期限
  field :payment_deadline, type: Integer #付款期限

  # 所属部门
  # belongs_to :department, foreign_key: :department_id

  #所属业务员
  # belongs_to :clerk, class_name:'Staff', foreign_key: :clerk_id  #业务员

  #往来单位 联系人详情
  # has_many :jxc_contacts_persons

  #采购单
  has_many :jxc_purchase_orders
  has_many :jxc_purchase_stock_in_bills
  has_many :jxc_purchase_returns_bills
  has_many :jxc_purchase_exchange_goods_bills
  #销售单
  has_many :jxc_sell_orders
  has_many :jxc_sell_stock_out_bills
  has_many :jxc_sell_returns_bills
  has_many :jxc_sell_exchange_goods_bills
  #其他出入库单据
  has_many :jxc_other_stock_in_bills
  has_many :jxc_other_stock_out_bills

  #各种单据商品详情
  has_many :jxc_bill_details

  # has_many :jxc_accounting_voucher_details #凭证明细

  def to_s
    unit_name
  end

end
