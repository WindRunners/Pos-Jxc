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

  index({customer_id: 1, product_ticket_id: 1}, { unique: true })

  #送礼人必须为小C
  def mobile_must_be_customer

    if !self.customer_id.present?
      customer = Customer.find_by_mobile(self.mobile)
      if !customer.present?
        errors.add(:mobile, "用户系统会员，请检查手机号!")
      else
        self.customer_id = customer.id.to_s #赋值
      end
    end

    temp = ProductTicketCustomerInit.where({:customer_id => self.customer_id}).first
    if temp.present? && temp['_id']!=self.id
      errors.add(:mobile, "当前用户已经添加，无需再添加!")
    end


  end

end