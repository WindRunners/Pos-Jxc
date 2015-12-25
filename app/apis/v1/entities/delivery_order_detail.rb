module Entities

  class DeliveryOrderDetail < Grape::Entity
    expose :id, documentation: {type: String, desc: '订单id'}
    expose :orderno, documentation: {type: String, desc: '订单号码'}
    expose :ordertype, documentation: {type: String, desc: '订单类型  0-线下订单  1-线上订单'}
    expose :consignee, documentation: {type: String, desc: '收货人'}
    expose :address, documentation: {type: String, desc: '收货人地址'}
    expose :telephone, documentation: {type: String, desc: '收货电话'}
    expose :totalcost, documentation: {type: Float, desc: '总费用'}
    expose :fright, documentation: {type: Float, desc: '运费'}
    expose :useintegral, documentation: {type: Integer, desc: '使用积分数量'}
    expose :paycost, documentation: {type: Float, desc: '支付金额'}
    expose :paymode, documentation: {type: Integer, desc: '支付方式 0-货到付款 1-支付宝 2-微信支付'}
    expose :ordergoods, documentation: {type: Ordergood, desc: '订单商品信息'}
    expose :remarks, documentation: {type: String, desc: '重要说明'}
    expose :workflow_state, documentation: {type: String, desc: '状态 generation:待付款,paid:待抢单,take:待接货,distribution:配送中,receive:配送完成,completed:确认收货,cancelled:取消订单'}
    expose :consignee_longitude, documentation: {type: Float, desc: '收货地址经度'}
    expose :consignee_latitude, documentation: {type: Float, desc: '收货地址纬度'}
    expose :store_longitude, documentation: {type: Float, desc: '门店经度'}
    expose :store_latitude, documentation: {type: Float, desc: '门店纬度'}


    expose :take_product_imgs,documentation: {type: Array, desc: '接货图片'}
    expose :current_distance, documentation: {type: Float, desc: '当前位置距离门店距离'}
    expose :distance, documentation: {type: Float, desc: '配送距离'}
    expose :store_address, documentation: {type: String, desc: '门店地址'}
  end
end
