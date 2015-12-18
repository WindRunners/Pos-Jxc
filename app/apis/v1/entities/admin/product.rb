module Entities::Admin
  class Product < Grape::Entity
    expose :id, documentation: {type: String, desc: '商品id'}
    expose :qrcode, documentation: {type: String, desc: '条码'}
    expose :title, documentation: {type: String, desc: '标题'}
    expose :specification, documentation: {type: String, desc: '产品规格'}
    expose :purchasePrice, documentation: {type: Float, desc: '进价'}
    expose :price, documentation: {type: Float, desc: '零售价'}
    expose :category_name, documentation: {type: String, desc: '商品类别'}
    expose :stock, documentation: {type: Integer, desc: '库存数量'}
    expose :alarm_stock, documentation: {type: Integer, desc: '预警库存数量'}
    expose :sale_count, documentation: {type: Integer, desc: '销量'}
    expose :avatar_url, documentation: {type: String, desc: '商品缩略图'}
    expose :main_url, documentation: {type: String, desc: '商品主图'}
    expose :status, documentation: {type: Float, desc: '商品状态'} do |object, options|
      object.state.value
    end
  end
end
