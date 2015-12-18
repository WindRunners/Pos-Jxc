module Entities
  class Coupon < Grape::Entity
    expose :id, documentation: {type: String, desc: '优惠卷id'}
    expose :title, documentation: {type: String, desc: '优惠卷标题'}
    expose :quantity, documentation: {type: Integer, desc: '优惠卷数量'}
    expose :value, documentation: {type: Float, desc: '优惠卷价值'}
    expose :limit, documentation: {type: String, desc: '每人限领个数'}
    expose :startTime, documentation: {type: String, desc: '生效时间'}
    expose :endTime, documentation: {type: String, desc: '过期时间'}
    expose :instructions, documentation: {type: Float, desc: '使用说明'}
    expose :order_amount_way, documentation: {type: String, desc: '订单使用限制 0:无限制, 1:看order_amount的值，满足才可使用'}
    expose :order_amount, documentation: {type: String, desc: '订单满多少可以使用'}
    expose :use_goods, documentation: {type: String, desc: '可使用的商品 0:全店能用,1:指定商品看products可使用的商品'}
    expose :buy_limit, documentation: {type: Boolean, desc: '是不是公原价商品可用, true:购买原价商品时才可使用, false:无限制'}
    expose :products, using: Entities::Product, documentation: {type: Product, desc: '指定使用的商品'}
  end
end
