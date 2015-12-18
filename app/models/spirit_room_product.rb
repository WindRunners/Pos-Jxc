class SpiritRoomProduct
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic

  field :count, type: Integer #商品数量
  field :mobile_category_name, type: String #商品类型
  field :product_id ,type: String #商品类型
  belongs_to :spirit_room
  belongs_to :userinfo
end