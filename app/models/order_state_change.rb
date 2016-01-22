class OrderStateChange
  include Mongoid::Document
  include Mongoid::Timestamps::Updated
  include Mongoid::Attributes::Dynamic

  belongs_to :userinfo

  field :customer_id
  field :paymode
  field :state
  field :orderno
  field :ordertype

end