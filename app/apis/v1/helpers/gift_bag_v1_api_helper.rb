module GiftBagV1APIHelper

  CUSTOMER_HEAD_URL = "/system/products/avatars/5603/c3a7/af48/436b/1600/00c0/original/%E6%A2%85%E8%A5%BF%E8%8A%8B%E5%A4%B4%E5%88%87%E7%89%8780g.jpg?1448351129"


  #礼包认领
  def GiftBagV1APIHelper.claim(customerUser, gift_bag_id)

    spiritRoom = SpiritRoom.where({'customer_id' => customerUser.id}).first
    return {msg: '当前会员未开通酒库,请开通后进行认领!', flag: 2} if !spiritRoom.present?

    giftBag = GiftBag.where(id: gift_bag_id).first
    return {msg: '当前礼包不存在!', flag: 0} if !giftBag.present?

    #判断礼包接受用户和认领用户是否一致
    return {msg: '礼包认领用户非当前用户!', flag: 0} if customerUser.mobile!=giftBag.receiver_mobile

    #判断认领时间是否过期
    return {msg: '礼包已过期!', flag: 0} if (giftBag.expiry_time.to_i-Time.now.to_i) < 0

    return {msg: '当前礼包已经领取,请查看酒库!', flag: 0} if giftBag.sign_status == 1

    #遍历礼包商品信息
    giftBag.product_list.each do |k, v|

      k_arry = k.to_s.split('_')
      product_id = k_arry[0] #商品id
      userinfo_id = k_arry[1] #运营商id

      spiritRoomProduct = SpiritRoomProduct.where(:spirit_room_id => spiritRoom.id, :product_id => product_id, :userinfo_id => userinfo_id).first #酒库商品
      product = Product.shop_id(userinfo_id).where(id: product_id).first #商品

      # next if !product.present?

      if spiritRoomProduct.present?
        spiritRoomProduct.count += v['count'] #累加
      else
        spiritRoomProduct = SpiritRoomProduct.new
        spiritRoomProduct['product_id'] = product_id
        spiritRoomProduct.count = v['count']
        spiritRoomProduct['userinfo_id'] = userinfo_id
        spiritRoomProduct.spirit_room = spiritRoom.id
        spiritRoomProduct['mobile_category_name'] = product.category_name
      end
      spiritRoomProduct.save! #更新
    end

    giftBag.sign_status = 1
    giftBag.receiver_customer_id = customerUser.id.to_s
    giftBag.sign_time = Time.now
    giftBag.save! #更新礼包状态

    spiritRoomLog = SpiritRoomLog.new
    spiritRoomLog.spirit_room = spiritRoom
    spiritRoomLog.gift_bag = giftBag
    spiritRoomLog.remarks = "签收礼包"
    spiritRoomLog.save

    #移除定时队列
    Resque.remove_delayed(AchieveGiftBagExpiry, gift_bag_id)
    #酒库信息保存
    return {msg: '礼包领取成功!', flag: 1}
  end


  #礼包认领
  def GiftBagV1APIHelper.claim_list(customerUser)

    giftBags = GiftBag.where(:receiver_mobile => customerUser.mobile, :expiry_time.gt => Time.now, :sign_status => 0).order('expiry_time desc')
    giftBagsBak = []
    #通过查询得到的集合,循环块内改变块内元素,不影响集合信息
    giftBags.each do |giftBag|

      customer = Customer.find(giftBag.customer_id)
      customer.head_url = CUSTOMER_HEAD_URL
      customer.name = customer.name.present? ? customer.name : ""
      giftBag['customer_info'] = customer
      giftBagsBak << giftBag
    end
    giftBagsBak
  end

  #已领取礼包
  def GiftBagV1APIHelper.has_claim_list(customer_id)

    giftBags = GiftBag.where(:receiver_customer_id => customer_id, :sign_status => 1)
  end

  #礼包历史列表
  def GiftBagV1APIHelper.his_list(customerUser)


    giftBags = GiftBag.where({"$or" => [{:customer_id=> customerUser.id.to_s}, {:receiver_customer_id =>customerUser.id.to_s}]}).order('updated_at desc')
    giftBagsBak = []
    #通过查询得到的集合,循环块内改变块内元素,不影响集合信息
    giftBags.each do |giftBag|
      source_mark = giftBag.receiver_customer_id == customerUser.id.to_s ? 1 : 0 #标识0:送出,1:收到
      customer = giftBag.customer_id == customerUser.id.to_s ? Customer.find_by_mobile(giftBag.receiver_mobile) : customerUser
      customer.head_url = CUSTOMER_HEAD_URL
      customer.name = customer.name.present? ? customer.name : ""
      giftBag['customer_info'] = customer
      giftBag['source_mark'] = source_mark
      giftBagsBak << giftBag
    end
    giftBagsBak
  end


  #发送礼包 送礼人,收礼人,商品列表,失效天数,祝福语
  def GiftBagV1APIHelper.send(customerUser, postInfo)

    spiritRoom = SpiritRoom.where({'customer_id' => customerUser.id}).first
    return {msg: '当前会员未开通酒库,请开通后进行认领!', flag: 2} if !spiritRoom.present?

    return {msg: '密码输入错误,请重新输入', flag: 3} if !spiritRoom.authenticate(postInfo.password)

    receiver_customerUser = Customer.find_by_mobile(postInfo.receiver_mobile);
    return {msg: '收礼人不存在,请检查账号!', flag: 0} if !receiver_customerUser.present?

    return {msg: '收礼人不能和送礼人相同!', flag: 0} if postInfo.receiver_mobile == customerUser.mobile
    userinfo_id = postInfo.userinfo_id #运营商id


    #获取酒库商品信息
    product_info = GiftBagV1APIHelper.get_spirit_product_info(spiritRoom,userinfo_id)

    gif_bag = GiftBag.new()
    gif_bag.receiver_mobile = postInfo.receiver_mobile
    gif_bag.expiry_days = postInfo.expiry_days
    gif_bag.expiry_time = Time.now+86400*postInfo.expiry_days
    gif_bag.sign_status = 0
    gif_bag.content = postInfo.content


    #赋值礼包商品及更新酒库商品数量
    gif_bag_product_list = {}
    product_list = JSON.parse(postInfo.product_list.to_s)

    #检查库存数量是否足够
    product_list.each do |product_id, product_count|
      puts "k: #{product_id},v: #{product_count}"
      return {msg: '请移除无效商品!', flag: 0} if !product_info[product_id.to_s].present?
      return {msg: '商品库存不够,请重新选择!', flag: 0} if product_info[product_id.to_s].to_i < product_count.to_i
    end
    product_list.each do |product_id, product_count|
      GiftBagV1APIHelper.update_spirit_product_info(spiritRoom, product_id, product_count.to_i, gif_bag_product_list,userinfo_id)
    end

    gif_bag.product_list = gif_bag_product_list
    gif_bag.customer_id = customerUser.id.to_s
    if gif_bag.save!

      spiritRoomLog = SpiritRoomLog.new
      spiritRoomLog.spirit_room = spiritRoom
      spiritRoomLog.gift_bag = gif_bag
      spiritRoomLog.remarks = "赠送礼包"
      spiritRoomLog.save

      Resque.enqueue_at(gif_bag.expiry_days.to_i.days.from_now, AchieveGiftBagExpiry, gif_bag.id.to_s)
      {msg: '礼包已发送成功!', flag: 1}
    else
      {msg: '礼包发送失败!', flag: 0}
    end
  end


  #礼包详细
  def GiftBagV1APIHelper.detail(customerUser, postInfo)

    # puts "postInfo:#{postInfo.to_json}"

    gift_bag_id = postInfo['gift_bag_id']
    spiritRoom = SpiritRoom.where({'customer_id' => customerUser.id}).first
    return {msg: '当前会员未开通酒库,请开通后进行认领!', flag: 2} if !spiritRoom.present?
    giftBag = GiftBag.where(id: gift_bag_id).first
    return {msg: '当前礼包不存在!', flag: 0} if !giftBag.present?

    #giftBag 增加的属性{flag:标识,customer:小C信息,product_list_info:商品列表信息,product_list_count:商品列表总数} 利于礼包渲染
    #信息标识
    giftBag['flag'] = 1
    #展示礼包对应小C信息(发送者or接受者)
    customer = giftBag.customer_id == customerUser.id.to_s ? Customer.find_by_mobile(giftBag.receiver_mobile) : customerUser
    customer.head_url = CUSTOMER_HEAD_URL
    customer.name = customer.name.present? ? customer.name : ""
    giftBag['customer_info'] = customer
    product_list = []
    product_count = 0
    #遍历礼包商品信息
    giftBag.product_list.each do |k, v|

      k_arry = k.to_s.split('_')
      product_id = k_arry[0] #商品id
      userinfo_id = k_arry[1] #运营商id
      product = Product.shop_id(userinfo_id).where(id: product_id).first #商品
      product['count'] = v['count']
      product_list << product
      product_count+= v['count']
    end
    giftBag['product_list_info'] = product_list
    giftBag['product_count'] = product_count
    giftBag
  end

  #同步失效礼包列表
  def GiftBagV1APIHelper.syn_expiry_gift_bags()

    expiry_list = GiftBag.where({"sign_status"=>0,"expiry_time"=>{"$lt"=> Time.now}}).limit(500)
    num = 0
    expiry_list.each do |gift_bag|
      #移除現有隊列
      Resque.remove_delayed(AchieveGiftBagExpiry, gift_bag.id.to_s)
      #添加隊列
      Resque.enqueue(AchieveGiftBagExpiry, gift_bag.id.to_s)
      num+=1
    end
    {msg: '同步失效礼包成功!', flag: 1, data: num}
  end

  private

  #获取酒库的商品信息{product_id:count}
  def GiftBagV1APIHelper.get_spirit_product_info(spiritRoom,userinfo_id)

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

    all_product_info_list = SpiritRoomProduct.where(:spirit_room_id => spiritRoom.id,:userinfo_id=>BSON::ObjectId(userinfo_id), :count.gt => 0).map_reduce(map, reduce).out(inline: true)
    all_product_info_list.each do |v|
      all_product_info[v['_id']] = v['value']
    end
    all_product_info
  end

  #更新酒库商品数量
  def GiftBagV1APIHelper.update_spirit_product_info(spiritRoom, product_id, count, gif_bag_product_list,userinfo_id)

    #减少酒库商品库存
    spiritRoomProducts = SpiritRoomProduct.where({:spirit_room_id => spiritRoom.id,:userinfo_id=>BSON::ObjectId(userinfo_id), :product_id => product_id, :count.gt => 0})

    spiritRoomProducts.each do |spiritRoomProduct|

      if spiritRoomProduct.count < count

        #赋值礼包商品列表
        gif_bag_product_list["#{product_id}_#{spiritRoomProduct['userinfo_id']}"] = {:count=>spiritRoomProduct.count}
        send_count = spiritRoomProduct.count
      else
        #赋值礼包商品列表
        gif_bag_product_list["#{product_id}_#{spiritRoomProduct['userinfo_id']}"] = {:count=>count}
        send_count = count
      end
      spiritRoomProduct.count -= send_count
      spiritRoomProduct.save! #更新
      count -= send_count #减少count的数量
      break if count <= 0
    end
  end


end