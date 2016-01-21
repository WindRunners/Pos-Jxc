class JxcSellExchangeGoodsBill
  ## 进销存 销售换货单
  include Mongoid::Document
  include Mongoid::Timestamps
  include JxcSettings

  field :bill_no, type: String            #单据编号
  field :customize_bill_no, type: String  #自定义单据编号
  field :collection_date, type: DateTime  #收款日期
  field :exchange_date, type: DateTime    #换货日期
  field :current_collection, type: Float  #当前收款
  field :remark, type: String             #备注


  field :total_amount, type: Float        #合计金额
  field :discount, type: Integer          #整单折扣
  field :discount_amount, type: Float     #整单优惠
  field :exchange_gap, type: Float        #换货差额
  field :bill_status, type: String        #单据状态

  belongs_to :consumer, class_name:'JxcContactsUnit' #客户
  has_and_belongs_to_many :exchange_out_stock, class_name:'JxcStorage'  #换出仓库
  has_and_belongs_to_many :exchange_in_stock, class_name:'JxcStorage'   #换入仓库
  belongs_to :handler, class_name:'Staff'   #经手人
  belongs_to :jxc_account    #收款账户
  belongs_to :bill_maker, class_name:'User'  #制单人

  has_many :in_products, class_name:'Product'   #换入商品明细
  has_many :out_products, class_name: 'Product'   #换出商品明细
end
