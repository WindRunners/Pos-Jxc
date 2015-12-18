module DeliveryOrderV1APIHelper
  include Math

  #配送员接单列表
  def DeliveryOrderV1APIHelper.take_order_list(deliveryUser, postInfo)

    current_lng = postInfo.longitude
    current_lat = postInfo.latitude

    store_ids = deliveryUser['store_ids'] #获取配送员负责的门店
    return [] if !store_ids.present? || store_ids.empty?

    take_orders = []
    #获取门店待接单列表
    orders = Order.where({'workflow_state' => 'paid', 'store_id' => {"$in" => store_ids}}).order('created_at desc')
    orders.each do |order|

      # deliveryOrder = DeliveryOrder.new
      # deliveryOrder['id'] = order.id
      # deliveryOrder['address'] = order.address
      # deliveryOrder['distance'] = order['distance']
      store = Store.find(order['store_id'])
      order['store_address'] = store.position
      if current_lng.present? && current_lat.present?
        order['current_distance'] = DeliveryOrderV1APIHelper.get_distance_for_points(current_lng, current_lat,store.location[0],store.location[1])
      else
        order['current_distance'] = 0
      end
      take_orders << order
    end

    take_orders
  end



  #配送员接单
  def DeliveryOrderV1APIHelper.take_order(deliveryUser, postInfo)

    order_id = postInfo['order_id'] #获取订单列表
    order = Order.where({'_id'=>order_id}).first
    return {msg: '当前订单不存在!', flag: 0} if !order.present?
    return {msg: '订单状态不合法!', flag: 0} if order.current_state.name.to_s!='paid'

    #接单
    order.take_order!
    #设置配送员属性
    Order.where(id: order_id).update({'delivery_user_id'=> deliveryUser.id.to_s})
    {msg: '接单成功!', flag: 1}
  end

  #订单配送完成
  def DeliveryOrderV1APIHelper.delivery_finished(deliveryUser, postInfo)

    order_id = postInfo['order_id'] #获取订单列表
    order = Order.where({'_id'=>order_id}).first
    return {msg: '当前订单不存在!', flag: 0} if !order.present?
    return {msg: '订单状态不合法!', flag: 0} if order.current_state.name.to_s!='distribution'

    #更改订单状态
    order.receive_goods!

    {msg: '恭喜您配送完成!', flag: 1}
  end



  #订单详细
  def DeliveryOrderV1APIHelper.order_detail(deliveryUser, postInfo)

    order_id = postInfo['order_id'] #获取订单列表
    current_lng = postInfo.longitude #当前位置坐标
    current_lat = postInfo.latitude #当前位置坐标

    order = Order.where({'_id'=>order_id}).first
    return {msg: '当前订单不存在!', flag: 0} if !order.present?
    store = Store.find(order['store_id'])
    order['store_address'] = store.position
    if current_lng.present? && current_lat.present?
      order['current_distance'] = DeliveryOrderV1APIHelper.get_distance_for_points(current_lng, current_lat,store.location[0],store.location[1])
    else
      order['current_distance'] = 0
    end

    #接货图片
    product_track = OrderTrack.where({'order_id'=>order_id,'state'=> 'distribution'}).first
    order['take_product_imgs'] = product_track.present? ? product_track.img_urls : []

    #获取商品
    order['ordergoods'] = order.ordergoods
    order
  end

  #我的订单列表
  def DeliveryOrderV1APIHelper.my_order_list(deliveryUser, postInfo)

    #包括状态[待接货,配送中,配送完成]
    orders = Order.where({'delivery_user_id'=> deliveryUser.id.to_s,'workflow_state'=>{'$in'=>['take','distribution','receive']}}).order('updated_at desc')
    my_orders = []
    orders.each do |order|
      store = Store.find(order['store_id'])
      order['store_address'] = store.position
      my_orders << order
    end
    my_orders
  end


  #配送员接单历史列表
  def DeliveryOrderV1APIHelper.my_order_hi_list(deliveryUser, postInfo)

    page = postInfo['page']
    #包括状态[确认收货,取消的]
    orders = Order.where({'delivery_user_id'=> deliveryUser.id.to_s,'workflow_state'=>{'$in'=>['cancelled','completed']}}).order('created_at desc').skip((page-1)*10).limit(10)
    my_his_orders = []
    orders.each do |order|
      store = Store.find(order['store_id'])
      order['store_address'] = store.position
      my_his_orders << order
    end
    my_his_orders
  end


  private

  #获取两坐标点的距离
  def DeliveryOrderV1APIHelper.get_distance_for_points(lng1, lat1, lng2, lat2)

    lat_diff = (lat1 - lat2)*PI/180.0
    lng_diff = (lng1 - lng2)*PI/180.0
    lat_sin = Math.sin(lat_diff/2.0) ** 2
    lng_sin = Math.sin(lng_diff/2.0) ** 2
    first = Math.sqrt(lat_sin + Math.cos(lat1*PI/180.0) * Math.cos(lat2*PI/180.0) * lng_sin)
    Math.asin(first) * 2 * 6378137.0
  end


end