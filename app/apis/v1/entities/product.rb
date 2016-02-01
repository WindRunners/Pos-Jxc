module Entities
  class Product < Grape::Entity
    expose :id, documentation: {type: String, desc: '商品id'}
    expose :qrcode, documentation: {type: String, desc: '条码'}
    expose :title, documentation: {type: String, desc: '标题'}
    expose :specification, documentation: {type: String, desc: '产品规格'}
    expose :price, documentation: {type: Float, desc: '零售价或活动价'} do |object, options|
      object.panic_price < 0.001 ? object.price : object.panic_price
    end
    expose :category_name, documentation: {type: String, desc: '商品类别'}
    expose :pid, documentation: {type: String, desc: '商品ID'}
    expose :stock, documentation: {type: Integer, desc: '库存数量或活动库存数量'} do |object, options|
      object.panic_quantity == 0 ? object.stock : object.panic_quantity
    end
    expose :sale_count, documentation: {type: Integer, desc: '销量'}
    expose :avatar_url, documentation: {type: String, desc: '商品缩略图'}
    expose :thumb_url, documentation: {type: String, desc: '商品大缩略图'} do |object, options|
      object.thumb_url.present? ? object.thumb_url : object.avatar_url
    end
    expose :tags, documentation: {type: String, desc: '商品标签'}

  end
end
