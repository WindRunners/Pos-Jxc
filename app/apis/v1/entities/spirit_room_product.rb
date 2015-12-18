module Entities
  class SpiritRoomProduct < Grape::Entity
    expose :id, documentation: {type: String, desc: '商品id'}
    expose :qrcode, documentation: {type: String, desc: '条码'}
    expose :title, documentation: {type: String, desc: '标题'}
    expose :store_count, documentation: {type: Integer, desc: '库存'}
    expose :avatar_url, documentation: {type: String, desc: '商品缩略图'}
    expose :category_name, documentation: {type: String, desc: '商品类别'}
  end
end
