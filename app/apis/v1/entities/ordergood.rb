module Entities
  class Ordergood < Grape::Entity
    expose :product_id, documentation: {type: String, desc: '商品id'}
    expose :qrcode, documentation: {type: String, desc: '条码'}
    expose :qrcode, documentation: {type: String, desc: '条码'}
    expose :specification, documentation: {type: String, desc: '产品规格'}
    expose :title, documentation: {type: String, desc: '品名'}
    expose :price, documentation: {type: Float, desc: '价格'}
    expose :integral, documentation: {type: Integer, desc: '积分'}
    expose :quantity, documentation: {type: Integer, desc: '数量'}
    expose :avatar_url, documentation: {type: String, desc: '商品缩略图'}
    expose :is_gift, documentation: {type: Boolean, desc: '是否赠品'}
  end
end


