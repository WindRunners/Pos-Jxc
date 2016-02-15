class JxcStorage
  #仓库
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic

  field :storage_name, type: String #仓库名称
  field :spell_code, type: String   #拼音码
  field :storage_code, type: String #仓库编码
  field :storage_type, type: String #仓库类型
  field :status, type: String, default: '0'  #仓库状态
  field :capacity, type: Integer  #仓库库容
  field :current_capacity, type: Integer  #仓库当前存量
  field :memo, type: String         #备注

  field :longitude, type:String #仓库地址 经度
  field :latitude, type:String #仓库地址  纬度
  field :address, type:String  #仓库详细地址信息
  field :telephone, type:String #仓库固定电话
  # field :admin, type:String  #仓库负责人姓名
  # field :admin_phone, type:String #仓库负责人手机


  field :data_1, type: String       #备用属性
  field :data_2, type: String
  field :data_3, type: String
  field :data_4, type: String

  belongs_to :admin, class_name:'User', foreign_key: :admin_id
  belongs_to :userinfo, foreign_key: :userinfo_id  #所属运营商
  belongs_to :store, foreign_key: :store_id #所属门店

  #采购单
  has_many :jxc_purchase_orders
  has_many :jxc_purchase_stock_in_bills
  has_many :jxc_purchase_returns_bills
  has_and_belongs_to_many :jxc_purchase_exchange_goods_bills
  #销售单
  has_many :jxc_sell_orders
  has_many :jxc_sell_stock_out_bills
  has_many :jxc_sell_returns_bills
  has_and_belongs_to_many :jxc_sell_exchange_goods_bills
  #库存变更单
  has_many :jxc_stock_count_bills #盘点单
  has_many :jxc_stock_overflow_bills  #报溢单
  has_many :jxc_stock_reduce_bills  #报损单
  has_and_belongs_to_many :jxc_stock_transfer_bills  #调拨单
  #其他出入库单据
  has_many :jxc_other_stock_in_bills
  has_many :jxc_other_stock_out_bills
  #其他单据
  # has_and_belongs_to_many :jxc_assemble_bills  #拆装单
  has_many :jxc_cost_adjust_bills #成本调整单


  has_many :jxc_bill_details  #单据商品详情
  has_and_belongs_to_many :jxc_transfer_bill_details  #调拨单 商品详情
  has_many :jxc_storage_journals  #仓库变更明细
  has_many :jxc_storage_product_details   #仓库商品明细

  def to_s
    self.storage_name
  end
end
