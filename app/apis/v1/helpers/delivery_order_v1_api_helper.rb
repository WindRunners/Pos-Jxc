module DeliveryOrderV1APIHelper
  include Math

  #配送员接单列表
  def DeliveryOrderV1APIHelper.take_order_list(deliveryUser, postInfo)

    current_lng = postInfo.longitude
    current_lat = postInfo.latitude
    page = postInfo['page']

    store_ids = deliveryUser['store_ids'] #获取配送员负责的门店
    return [] if !store_ids.present? || store_ids.empty?

    take_orders = []
    store_info = DeliveryOrderV1APIHelper.get_stores_by_userinfo_id(deliveryUser['userinfo_id'].to_s)
    #获取门店待接单列表
    orders = Order.where({'workflow_state' => 'paid', 'store_id' => {"$in" => store_ids}}).order('created_at desc').page(page).per(20)
    orders.each do |order|

      store = store_info[order['store_id']]
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
    return {msg: '下手慢了，当前订单已被抢!', flag: 0} if order.current_state.name.to_s!='paid'

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

    isEnd = false
    order = Order.where({'_id'=>order_id}).first

    if !order.present?
      isEnd = true
      order = Ordercompleted.where({'_id'=>order_id}).first
    end

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

    #收货人经纬度
    order['consignee_longitude'] = order.location[1]
    order['consignee_latitude'] = order.location[0]

    #门店经纬度
    order['store_longitude'] = store.location[0]
    order['store_latitude'] = store.location[1]

    #获取商品
    order['ordergoods'] = isEnd ? order.ordergoodcompleteds : order.ordergoods
    order
  end

  #我的订单列表
  def DeliveryOrderV1APIHelper.my_order_list(deliveryUser, postInfo)

    current_lng = postInfo.longitude
    current_lat = postInfo.latitude
    page = postInfo['page']

    #包括状态[待接货,配送中,配送完成]
    orders = Order.where({'delivery_user_id'=> deliveryUser.id.to_s,'workflow_state'=>{'$in'=>['take','distribution','receive']}}).order('updated_at desc').page(page).per(20)
    my_orders = []
    store_info = DeliveryOrderV1APIHelper.get_stores_by_userinfo_id(deliveryUser['userinfo_id'])
    orders.each do |order|
      store = store_info[order['store_id']]
      order['store_address'] = store.position
      if current_lng.present? && current_lat.present?
        order['current_distance'] = DeliveryOrderV1APIHelper.get_distance_for_points(current_lng, current_lat,store.location[0],store.location[1])
      else
        order['current_distance'] = 0
      end
      my_orders << order
    end
    my_orders
  end


  #配送员接单历史列表
  def DeliveryOrderV1APIHelper.my_order_hi_list(deliveryUser, postInfo)

    page = postInfo['page']
    #包括状态[确认收货,取消的]
    orders = Ordercompleted.where({'delivery_user_id'=> deliveryUser.id.to_s,'workflow_state'=>{'$in'=>['cancelled','completed']}}).order('created_at desc').page(page).per(20)
    my_his_orders = []
    store_info = DeliveryOrderV1APIHelper.get_stores_by_userinfo_id(deliveryUser['userinfo_id'])
    orders.each do |order|
      store = store_info[order['store_id']]
      order['store_address'] = store.position
      my_his_orders << order
    end
    my_his_orders
  end


  #配送员接单列表
  def DeliveryOrderV1APIHelper.order_rows(deliveryUser, postInfo)

    flag = postInfo.flag
    if flag==0 #待接单

      store_ids = deliveryUser['store_ids'] #获取配送员负责的门店
      return 0 if !store_ids.present? || store_ids.empty?
      #获取门店待接单列表
      return Order.where({'workflow_state' => 'paid', 'store_id' => {"$in" => store_ids}}).count
    elsif flag==1 #我的订单

      return Order.where({'delivery_user_id'=> deliveryUser.id.to_s,'workflow_state'=>{'$in'=>['take','distribution','receive']}}).count
    else #历史订单

      return Ordercompleted.where({'delivery_user_id'=> deliveryUser.id.to_s,'workflow_state'=>{'$in'=>['cancelled','completed']}}).count
    end
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


  #获取当前单位的单位
  def DeliveryOrderV1APIHelper.get_stores_by_userinfo_id(userinfo_id)

    storeinfo = {}
    Store.where({'userinfo_id'=>userinfo_id}).each do |store|
      storeinfo[store.id] = store
    end
    storeinfo
  end


end