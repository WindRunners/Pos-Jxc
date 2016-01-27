class ProductTicketCustomerInit
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  field :desc, type: String #备注
  field :customer_id, type: String
  field :mobile, type: String


  belongs_to :product_ticket

  validates :mobile, presence: true, format: {with: /\A\d{11}\z/, message: "手机号不合法!"}
  validate :mobile_must_be_customer

  #送礼人必须为小C
  def mobile_must_be_customer

    if !self.customer_id.present?
      customer = Customer.find_by_mobile(self.mobile)
      if !customer.present?
        errors.add(:sender_mobile, "用户系统会员，请检查手机号!")
      else
        self.customer_id = customer.id.to_s #赋值
      end
    end
  end

end