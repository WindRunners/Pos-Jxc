class CardBag
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  field :customer_id, type: String
  field :start_date, type: DateTime
  field :end_date, type: DateTime
  field :status, type: Integer,default: 0#0,未失效，-1，邀请成功
  field :register_customer_count, type: Integer,default: 0
  field :login_customer_count, type: Integer,default: 0
  field :source, type: Integer#0,小B导入，1，注册所得



  belongs_to :product_ticket


end
