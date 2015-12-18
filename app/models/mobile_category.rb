class MobileCategory
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Taggable

  belongs_to :userinfo

  field :title
  field :num, type: Integer, default:0

  #validates :title, presence: true, uniqueness: true

  def product_count
    Product.shop_id(userinfo.id).where(mobile_category_id:self.id).size
  end

  def products
    Product.shop_id(userinfo.id).where(mobile_category_id:self.id)
  end

  def to_s
    title
  end
end
