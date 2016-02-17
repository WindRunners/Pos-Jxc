class Ordergoodcompleted
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :ordercompleted

  field :product_id
  field :qrcode
  field :specification
  field :title
  field :purchasePrice , type: Float,default: 0.00 #进价
  field :price, type: Float #
  field :integral, type: Integer #积分
  field :quantity, type: Integer
  field :avatar
  field :is_gift,type: Boolean, default: false

  def avatar_url
    if self.avatar.present?
      RestConfig::PRODUCT_SERVER + self.avatar
    else
      "#{RestConfig::ELEPHANT_HOST}missing.png"
    end
  end

  def product
    @product ||= Product.shop_id(self.ordercompleted.userinfo.id).find(self.product_id)
  end

  after_save do
    product = self.product
    if 0 == self.ordercompleted.ordertype && :completed == self.ordercompleted.workflow_state.to_sym
      product.shop_id(self.ordercompleted.userinfo.id).update_attributes!(:stock => product.stock - self.quantity, :sale_count => product.sale_count + self.quantity) #库存核销
    elsif 1 == self.ordercompleted.ordertype && :cancelled == self.ordercompleted.workflow_state.to_sym
      if !product.panic_buying.nil? && (1 == product.panic_buying.state)
        product.shop_id(self.ordercompleted.userinfo.id).update_attributes!(:stock => product.stock + self.quantity, :panic_quantity => product.panic_quantity + self.quantity, :sale_count => product.sale_count - self.quantity,:panic_sale_count => product.panic_sale_count - self.quantity) #库存核增
      else
        product.shop_id(self.ordercompleted.userinfo.id).update_attributes!(:stock => product.stock + self.quantity, :sale_count => product.sale_count - self.quantity) #库存核增
      end
    end
  end
end
