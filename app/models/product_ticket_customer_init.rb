class ProductTicketCustomerInit
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  field :desc, type: String #备注
  field :customer_id, type: String
  field :mobile, type:String #小C手机号

  belongs_to :product_ticket

end