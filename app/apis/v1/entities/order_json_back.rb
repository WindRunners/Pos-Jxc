module Entities
  class OrderJsonBack < Grape::Entity
    expose :state, documentation: {type: Integer, desc: '状态码：200-成功！601-库存不足 602-活动结束 603-优惠券过期'}
    expose :products, documentation: {type: Array, desc: '[{"qrcode":"商品货号","stock":库存数量},{"qrcode":"商品货号","stock":库存数量}]'}, if: lambda { |orderjsonback, options| orderjsonback.state == 601 }
    expose :fullReductions, documentation: {type: Array, desc: '["活动ID","活动ID"]'}, if: lambda { |orderjsonback, options| orderjsonback.state == 602 }
    expose :coupon_id, documentation: {type: Array, desc: '["优惠券ID","优惠券ID"]'}, if: lambda { |orderjsonback, options| orderjsonback.state == 603 }
    expose :order, using: Entities::Order, documentation: {type: Order, desc: '订单对象'}, if: lambda { |orderjsonback, options| orderjsonback.state == 200 }
  end
end