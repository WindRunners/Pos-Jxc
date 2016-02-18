class ExpiredWarningProduct
  #过期预警商品列表
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  include Mongoid::Multitenancy::Document

  tenant(:client)

  field :resource_product_id, type:String #过期预警商品 ID
  field :current_inventory, type:Integer #当前库存存量

  has_one :jxc_storage, foreign_key: :storage_id #预警仓库


end
