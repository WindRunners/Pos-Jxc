module SpiritRoomV1APIHelper

  #酒库创建
  def SpiritRoomV1APIHelper.create(customerUser, password)

    spiritRoom = SpiritRoom.where(:customer_id => customerUser.id).first
    return {msg: '酒库已经开通,请查看!', flag: 0} if spiritRoom.present?

    spiritRoom = SpiritRoom.new(:password => password)
    spiritRoom['customer_id'] = customerUser.id.to_s
    spiritRoom.save
    return {msg: '酒库创建成功!', flag: 1}
  end

  #酒库商品类型列表
  def SpiritRoomV1APIHelper.category_list(customerUser)

    # puts "小C信息为:#{Customer.all.first.to_json}"

    spiritRoom = SpiritRoom.where({'customer_id' => customerUser.id}).first
    return {msg: '当前会员未开通酒库,请开通后进行认领!', flag: 2} if !spiritRoom.present?

    map = %Q{
        function(){
          emit(this.mobile_category_name,this.count)
        }
      }

    reduce = %Q{

        function(key,values){
          return Array.sum(values);
        }
      }

    info_list = SpiritRoomProduct.where(:spirit_room_id => spiritRoom.id, :count.gt => 0).map_reduce(map, reduce).out(inline: true)

    mobile_category_list = []
    info_list.each do |v|
      mobile_category = {'mobile_category_name' => v['_id'], 'count' => v['value']}
      mobile_category_list << mobile_category
    end
    return mobile_category_list
  end

  #酒库商品类型列表
  def SpiritRoomV1APIHelper.product_list(customerUser)

    spiritRoom = SpiritRoom.where({'customer_id' => customerUser.id}).first
    return {msg: '当前会员未开通酒库,请开通后进行认领!', flag: 2} if !spiritRoom.present?

    spiritRoomProducts = spiritRoom.spirit_room_products.where(:count.gt => 0).order('updated_at desc')

    productMap = {}
    spiritRoomProducts.each do |spiritRoomProduct|

      product = productMap[spiritRoomProduct.product_id]
      if product.present?
        product['store_count'] += spiritRoomProduct.count
      else
        product = Product.shop_id(spiritRoomProduct['userinfo_id']).find(spiritRoomProduct.product_id) #商品
        product['store_count'] = spiritRoomProduct.count
        productMap[spiritRoomProduct.product_id] = product
      end
    end
    productMap.values
  end


  #酒库提酒
  def SpiritRoomV1APIHelper.take_product(customerUser, postInfo)

    spiritRoom = SpiritRoom.where({'customer_id' => customerUser.id}).first
    return {msg: '当前会员未开通酒库,请开通后进行认领!', flag: 2} if !spiritRoom.present?

    #获取酒库商品信息
    product_info = SpiritRoomV1APIHelper.get_spirit_product_info(spiritRoom)
    product_list = JSON.parse(postInfo.product_list.to_s)

    #检查库存数量是否足够
    product_list.each do |product_id, product_count|
      return {msg: '请移除无效商品!', flag: 0} if !product_info[product_id.to_s].present?
      return {msg: '商品库存不够,请重新选择!', flag: 0} if product_info[product_id.to_s].to_i < product_count.to_i
    end

    b_product_order_info = {} #商品按小B分割后的订单信息
    b_syn_spirit_product_info = [] #需要同步的酒库商品列表

    #俺小B进行提取酒
    product_list.each do |product_id, product_count|

      p_count = product_count

      spirit_product_list = SpiritRoomProduct.where({:spirit_room_id => spiritRoom.id, :count.gt => 0, 'product_id' => product_id})
      spirit_product_list.each do |spirit_product|

        break if p_count==0 #商品数量为零时跳出循环
        reduce_count = 0 #减少的数量
        if spirit_product.count > p_count
          reduce_count = p_count
        else
          reduce_count = spirit_product.count
        end
        spirit_product.count -= reduce_count
        p_count -= reduce_count

        #单位的订单信息
        order_info = b_product_order_info[spirit_product['userinfo_id']].present? ? b_product_order_info[spirit_product['userinfo_id']] : {}
        syn_spirit_product_list = b_syn_spirit_product_info[spirit_product['userinfo_id']].present? ? b_syn_spirit_product_info[spirit_product['userinfo_id']] : []

        order_info[product_id] = reduce_count
        syn_spirit_product_list << spirit_product
      end
    end

    result_list = []
    #循环小B商品订单,生成订单
    b_product_order_info.each do |userinfo_id, product_info|

      #按指定小B生成订单
      result = SpiritRoomV1APIHelper.create_spirit_order(customerUser, userinfo_id, product_info, postInfo)
      if result['flag'] == 1
        b_syn_spirit_product_info[userinfo_id].each do |spirit_product|
          spirit_product.save!
        end
      end
      result_list << result
    end
    return {msg: '酒库提酒成功!', flag: 1, data: result_list}
  end


  private
  #获取酒库的商品信息{product_id:count}
  def SpiritRoomV1APIHelper.get_spirit_product_info(spiritRoom)

    all_product_info = {}
    map = %Q{
        function(){
          emit(this.product_id,this.count)
        }
      }
    reduce = %Q{

        function(key,values){
          return Array.sum(values);
        }
      }

    all_product_info_list = SpiritRoomProduct.where(:spirit_room_id => spiritRoom.id, :count.gt => 0).map_reduce(map, reduce).out(inline: true)
    all_product_info_list.each do |v|
      all_product_info[v['_id']] = v['value']
    end
    all_product_info
  end

  def SpiritRoomV1APIHelper.create_spirit_order(customerUser, userinfo_id, product_info, postInfo)

    consignee = postInfo['consignee']
    address = postInfo['address']
    mobile = postInfo['mobile']
    longitude = postInfo['longitude']
    latitude = postInfo['latitude']

    #订单生成
    order = Order.new(:ordertype => 1,
                      :consignee => consignee,
                      :telephone => mobile,
                      :address => address,
                      :location => [longitude, latitude],
                      :paymode => 3,
                      :remarks => orderjson["remarks"],
                      :userinfo => userinfo_id,
                      :customer_id => customerUser['_id'].to_s)
    order.orderno = SpiritRoomV1APIHelper.create_orderno


    #订单商品生成
    ordergoods_list = []
    product_info.each do |product_id, product_count|

      product = Product.shop_id(product_id).find(product_id)
      ordergood = Ordergood.new(:product_id => product['_id'].to_s,
                                :specification => product.specification,
                                :qrcode => product.qrcode,
                                :title => product.title,
                                :purchasePrice => product.purchasePrice,
                                :quantity => product_count,
                                :avatar_url => product.avatar_url)
      ordergoods_list<<ordergood
    end
    order.ordergoods = ordergoods_list

    if order.spirit_order_creat!
      {msg: '订单创建成功!', flag: 1, data: order.orderno}
    else
      {msg: '订单创建失败!', flag: 0, data: order.orderno}
    end
  end


  def SpiritRoomV1APIHelper.create_orderno
    time = Time.now
    return time.strftime("%Y%m%d%H%M%S") + time.usec.to_s
  end



end