module Entities
  class Order < Grape::Entity
    expose :id, documentation: {type: String, desc: '订单id'}
    expose :orderno, documentation: {type: String, desc: '订单号'}, if: lambda { |order, options| !order.orderno.nil?}
    expose :consignee, documentation: {type: String, desc: '收货人'}, if: lambda { |order, options| !order.consignee.nil? && !order.consignee.empty?}
    expose :address, documentation: {type: String, desc: '收获地址'}, if: lambda { |order, options| !order.address.nil? && !order.address.empty?}
    expose :telephone, documentation: {type: String, desc: '联系方式'}, if: lambda { |order, options| !order.telephone.nil? && !order.telephone.empty?}
    expose :totalcost, documentation: {type: Float, desc: '总费用'}
    expose :fright, documentation: {type: Float, desc: '配送费'}
    expose :paymode, documentation: {type: Integer, desc: '支付方式'}, if: lambda { |order, options| !order.paymode.nil?}
    expose :paycost, documentation: {type: Float, desc: '支付金额'}
    expose :customer_integral, documentation: {type: Integer, desc: '小C积分'}
    expose :useintegral, documentation: {type: Integer, desc: '可使用积分'}
    expose :getintegral, documentation: {type: Integer, desc: '获赠积分数量'}
    expose :totalquantity, documentation: {type: Integer, desc: '商品总数量'}
    expose :created_at, documentation: {type: Date, desc: '创建时间'} do |order, options|
      order.created_at = order.created_at.strftime("%Y-%m-%d %H:%M:%S") if !order.created_at.nil?
    end
    expose :ordergoods, using: Entities::Ordergood, documentation: {type: Ordergood, desc: '订单商品集合'}, if: lambda { |order, options| !order.ordergoods.nil? && !order.ordergoods.empty? }
    expose :activities, documentation: {type: String, desc: '活动列表', is_array: true}, if: lambda { |order, options| !order.activities.nil? && !order.activities.empty? }
    expose :coupons, documentation: {type: String, desc: '可用优惠券列表', is_array: true}
    expose :getcoupons, documentation: {type: String, desc: '获赠优惠券列表', is_array: true}
    expose :workflow_state, documentation: {type: String, desc: '订单状态'}, if: lambda { |order, options| !order.workflow_state.nil?}
    expose :lng, documentation: {type: String, desc: '经度'}
    expose :lat, documentation: {type: String, desc: '纬度'}
    expose :remarks, documentation: {type: String, desc: '备注'}

  end
end


