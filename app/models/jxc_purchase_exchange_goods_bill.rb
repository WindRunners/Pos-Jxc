class JxcPurchaseExchangeGoodsBill
  ##  采购换货单
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Multitenancy::Document

  tenant(:client)

  field :bill_no, type: String            #单据编号
  field :customize_bill_no, type: String  #自定义单据编号
  field :payment_date, type: DateTime     #付款日期
  field :exchange_date, type: DateTime    #换货日期
  field :current_payment, type: Float     #本次付款
  field :remark, type: String             #备注

  field :total_amount, type: Float        #合计金额
  field :discount, type: Integer          #整单折扣
  field :discount_amount, type: Float     #整单优惠
  field :exchange_gap, type: Float        #换货差额
  field :bill_status, type: String        #单据状态

  belongs_to :supplier, class_name:'JxcContactsUnit' #供应商
  has_and_belongs_to_many :exchange_out_stock, class_name: 'JxcStorage'     #换出仓库
  has_and_belongs_to_many :exchange_in_stock, class_name: 'JxcStorage'      #换入仓库
  # belongs_to :jxc_account  #付款账户
  has_and_belongs_to_many :handler, class_name:'User' #经手人
  has_and_belongs_to_many :bill_maker, class_name:'User' #制单人

  has_many :out_products, class_name:'Product'  #换出商品明细
  has_many :in_products, class_name:'Product'   #换入商品明细
end
