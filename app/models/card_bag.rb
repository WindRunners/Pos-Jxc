class CardBag
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  field :customer_id, type: String
  field :status, type: Integer,default: 0#0,未失效，-1，失效
  field :register_customer_count, type: Integer,default: 0
  field :login_customer_count, type: Integer,default: 0
  field :source, type: Integer
  belongs_to :product_ticket#0,小B导入，1，注册所得
end
