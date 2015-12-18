class UserinfoOrder
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :userinfo

  field :paymode, type: Integer
  field :money, type: Integer
  field :state, type: Integer, default: 0  #0微支付 1已支付

end
