module Entities
  class Ordercompleted < Grape::Entity
    expose :id, documentation: {type: String, desc: '订单id'}
    expose :orderno, documentation: {type: String, desc: '订单号'}
    expose :consignee, documentation: {type: String, desc: '收货人'}
    expose :address, documentation: {type: String, desc: '收获地址'}
    expose :telephone, documentation: {type: String, desc: '联系方式'}
    expose :totalcost, documentation: {type: Float, desc: '总费用'}
    expose :fright, documentation: {type: Float, desc: '配送费'}
    expose :paymode, documentation: {type: Integer, desc: '支付方式'}
    expose :paycost, documentation: {type: Float, desc: '支付金额'}
    expose :useintegral, documentation: {type: Integer, desc: '可使用积分'}
    expose :getintegral, documentation: {type: Integer, desc: '获赠积分数量'}
    expose :totalquantity, documentation: {type: Integer, desc: '商品总数量'}
    expose :created_at, documentation: {type: Date, desc: '创建时间'} do |order, options|
      order.created_at = order.created_at.strftime("%Y-%m-%d %H:%M:%S") if !order.created_at.nil?
    end
    expose :ordergoodcompleteds, using: Entities::Ordergoodcompleted, documentation: {type: Ordergoodcompleted, desc: '订单商品集合'}
    expose :getcoupons, documentation: {type: String, desc: '获赠优惠券列表', is_array: true}
    expose :workflow_state, documentation: {type: String, desc: '订单状态'}
  end
end


