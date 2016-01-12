module SpiritRoomV1APIHelper

  RESET_PWD_VERIFYCODE_PREFIX = "spiritRoomResetPwd" #定义配送员注册验证码前缀
  EXPIRY_TIMES = 60000 #验证码失效时间10分钟

  #酒库创建
  def SpiritRoomV1APIHelper.create(customerUser, password)

    return {msg: '密码不合法，请重新输入', flag: 0} if !SpiritRoomV1APIHelper.pwd_regex(password)

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
        product = Product.shop_id(spiritRoomProduct['userinfo_id']).where({'id'=>spiritRoomProduct.product_id}).first #商品
        next if !product.present?
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

    return {msg: '密码输入错误,请重新输入', flag: 3} if !spiritRoom.authenticate(postInfo.password)

    userinfo_id = postInfo['userinfo_id'] #小B id

    #获取当前单位的酒库商品信息
    product_info = SpiritRoomV1APIHelper.get_spirit_product_info(spiritRoom,userinfo_id)
    product_list = JSON.parse(postInfo.product_list.to_s)

    #检查库存数量是否足够
    product_list.each do |product_id, product_count|
      return {msg: '请移除无效商品!', flag: 0} if !product_info[product_id.to_s].present?
      return {msg: '当前单位商品库存不够,请重新选择!', flag: 0} if product_info[product_id.to_s].to_i < product_count.to_i
    end
    syn_spirit_product_list = [] #需要同步的酒库商品列表

    #俺小B进行提取酒
    product_list.each do |product_id, product_count|

      spirit_product = SpiritRoomProduct.where({:spirit_room_id => spiritRoom.id,:userinfo_id => BSON::ObjectId(userinfo_id), :count.gt => 0, 'product_id' => product_id}).first
      spirit_product.count -= product_count
      syn_spirit_product_list << spirit_product
    end

    #按指定小B生成订单
    result = SpiritRoomV1APIHelper.create_spirit_order(customerUser, userinfo_id, product_list, postInfo)
    if result[:flag] == 1
      syn_spirit_product_list.each do |spirit_product|
        spirit_product.save!
      end
      return {msg: '酒库提酒成功!', flag: 1, data: result['data']}
    else
      return {msg: '酒库提酒失败!', flag: 0}
    end
  end


  #酒库修改密码
  def SpiritRoomV1APIHelper.update_pwd(customerUser, postInfo)
    old_pwd = postInfo['old_password']
    new_pwd = postInfo['new_password']

    return {msg: '旧密码不合法，请重新输入', flag: 0} if !SpiritRoomV1APIHelper.pwd_regex(old_pwd)
    return {msg: '新密码不合法，请重新输入', flag: 0} if !SpiritRoomV1APIHelper.pwd_regex(new_pwd)

    spiritRoom = SpiritRoom.where(:customer_id => customerUser.id).first
    return {msg: '当前用户为开通酒库!', flag: 0} if !spiritRoom.present?

    return {msg: '旧密码输入错误,请重新输入', flag: 0} if !spiritRoom.authenticate(old_pwd)

    spiritRoom.password = new_pwd.to_s
    if spiritRoom.save!
      return {msg: '酒库密码修改成功!', flag: 1}
    else
      return {msg: '酒库密码修改失败!', flag: 0}
    end

  end


  #酒库重置密码
  def SpiritRoomV1APIHelper.reset_pwd(customerUser, postInfo)
    verifycode = postInfo['verifycode']
    new_pwd = postInfo['new_password']

    return {msg: '新密码不合法，请重新输入', flag: 0} if !SpiritRoomV1APIHelper.pwd_regex(new_pwd)

    spiritRoom = SpiritRoom.where(:customer_id => customerUser.id).first
    return {msg: '当前用户为开通酒库!', flag: 0} if !spiritRoom.present?

    #验证码验证
    verifycode2 = VerifyCode.where(key: "#{RESET_PWD_VERIFYCODE_PREFIX}_#{customerUser.mobile}").first #获取验证码
    if !verifycode2.present?
      return {msg: '验证码不存在,请重新获取', flag: 0}
    elsif verifycode2.code != verifycode #验证码不一致
      return {msg: '验证码错误,请重新输入', flag: 0}
    elsif Time.now - verifycode2["updated_at"] > EXPIRY_TIMES #有效期一分钟
      return {msg: '验证码失效,请重新获取', flag: 0}
    end

    spiritRoom.password = new_pwd.to_s
    if spiritRoom.save!
      verifycode2.delete #销毁验证码
      {msg: '酒库密码修改成功!', flag: 1}
    else
      {msg: '酒库密码修改失败!', flag: 1}
    end
  end


  #获取酒库重置密码验证码
  def SpiritRoomV1APIHelper.get_reset_pwd_verifycode(customerUser)

    mobile = customerUser.mobile

    veriycode = SpiritRoomV1APIHelper.create_veriycode #生成验证码
    veriycode2 = VerifyCode.where(key: "#{RESET_PWD_VERIFYCODE_PREFIX}_#{mobile}").first #获取配送员注册验证码

    if veriycode2.present?
      veriycode2.code = veriycode
    else
      veriycode2 = VerifyCode.new(key: "#{RESET_PWD_VERIFYCODE_PREFIX}_#{mobile}", code: veriycode)
    end

    #更新验证码
    veriycode2.save
    ChinaSMS.use :yunpian, password: '9525738f52010b28d1b965e347945364'

    # 通用接口
    ChinaSMS.to mobile, '【酒运达】您的酒库密码重置验证码是' + veriycode
    {msg: '验证码已发送,请稍后...', flag: 1,data: veriycode}
  end



  private
  #获取酒库的商品信息{product_id:count}
  def SpiritRoomV1APIHelper.get_spirit_product_info(spiritRoom,userinfo_id)

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

    all_product_info_list = SpiritRoomProduct.where(:spirit_room_id => spiritRoom.id,:userinfo_id => BSON::ObjectId(userinfo_id), :count.gt => 0).map_reduce(map, reduce).out(inline: true)
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
                      :userinfo_id => BSON::ObjectId(userinfo_id),
                      :customer_id => customerUser.id)
    order.orderno = SpiritRoomV1APIHelper.create_orderno


    #订单商品生成
    ordergoods_list = []
    product_info.each do |product_id, product_count|

      product = Product.shop_id(userinfo_id).find(BSON::ObjectId(product_id))
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
      return {msg: '订单创建成功!', flag: 1, data: order.orderno}
    else
      return {msg: '订单创建失败!', flag: 0, data: order.orderno}
    end
  end


  def SpiritRoomV1APIHelper.create_orderno
    time = Time.now
    return time.strftime("%Y%m%d%H%M%S") + time.usec.to_s
  end


  def SpiritRoomV1APIHelper.pwd_regex(pwd)

    pwd.present? && !pwd.match(/^\d{6}$/).nil?
  end

  #创建验证码
  def SpiritRoomV1APIHelper.create_veriycode

    code = ''
    for i in 0..5
      code.concat(rand(9).to_s)
    end
    return code
  end


end