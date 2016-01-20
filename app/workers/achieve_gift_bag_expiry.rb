class AchieveGiftBagExpiry

  @queue = :achieves_queue_gift_bag_expiry

  #礼包失效商品返回送礼人酒库
  def self.perform(gift_bag_id)

    # puts "礼包失效执行,礼包id为:#{gift_bag_id}"

    giftBag = GiftBag.find(gift_bag_id)
    # puts "礼包失效执行,礼包id为1:#{gift_bag_id}"
    return if giftBag.sign_status==-1 || giftBag.sign_status==1 #已经失效或者,已签收时,直接返回
    # puts "礼包失效执行,礼包id为2:#{gift_bag_id}"
    update_spirit_product_info(giftBag)
    # puts "礼包失效执行结束,礼包id为3:#{gift_bag_id}"
  end

  private

  #更新酒库商品数量
  def self.update_spirit_product_info(giftBag)
    customerUser = Customer.find(giftBag.customer_id)
    spiritRoom = SpiritRoom.where({'customer_id' => customerUser.id.to_s}).first
    return if !spiritRoom.present?

    spiritRoomLog = SpiritRoomLog.new
    spiritRoomLog.spirit_room = spiritRoom
    spiritRoomLog.gift_bag = giftBag
    spiritRoomLog.remarks = "礼包失效返回酒库"
    spiritRoomLog.save

    #遍历礼包商品信息
    giftBag.product_list.each do |k, v|

      k_arry = k.to_s.split('_')
      product_id = k_arry[0] #商品id
      userinfo_id = k_arry[1] #运营商id

      spiritRoomProduct = SpiritRoomProduct.where(:spirit_room_id => spiritRoom.id, :product_id => product_id, :userinfo_id => userinfo_id).first #酒库商品
      product = Product.shop_id(userinfo_id).where(id: product_id).first #商品

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
    giftBag.sign_status = -1
    giftBag.save! #更新礼包状态
  end

end