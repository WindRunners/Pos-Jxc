class Ordergood
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :order

  field :product_id
  field :specification
  field :qrcode
  field :title
  field :purchasePrice, type: Float,default: 0.00 #进价
  field :price, type: Float,default: 0.00 #
  field :integral, type: Integer,default: 0 #积分
  field :quantity, type: Integer,default: 0
  field :avatar
  field :is_gift,type: Boolean, default: false


  def avatar_url
    self.avatar ||= 'missing.png'
    RestConfig::PRODUCT_SERVER + self.avatar
  end

  def product
    @product ||= Product.shop_id(self.order.userinfo.id).find(self.product_id)
  end

  after_save do
    product = self.product
    if :generation == self.order.workflow_state.to_sym || :paid == self.order.workflow_state.to_sym
      if !product.panic_buying.nil? && (1 == product.panic_buying.state)
        product.shop_id(self.order.userinfo.id).update_attributes!(:stock => product.stock - self.quantity, :panic_quantity => product.panic_quantity - self.quantity, :sale_count => product.sale_count + self.quantity,:panic_sale_count => product.panic_sale_count + self.quantity) #库存核销
      else
        product.shop_id(self.order.userinfo.id).update_attributes!(:stock => product.stock - self.quantity, :sale_count => product.sale_count + self.quantity) #库存核销
      end
    end
  end
end

