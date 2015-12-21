module SpiritRoomV1APIHelper

  #酒库创建
  def SpiritRoomV1APIHelper.create(customerUser,password)

    spiritRoom = SpiritRoom.where(:customer_id => customerUser.id).first
    return {msg: '酒库已经开通,请查看!', flag: 0} if spiritRoom.present?

    spiritRoom = SpiritRoom.new(:password=>password)
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

    info_list =  SpiritRoomProduct.where(:spirit_room_id =>spiritRoom.id,:count.gt => 0).map_reduce(map, reduce).out(inline: true)

    mobile_category_list = []
    info_list.each do |v|
      mobile_category = {'mobile_category_name'=>v['_id'],'count'=>v['value']}
      mobile_category_list << mobile_category
    end
    return mobile_category_list
  end

  #酒库商品类型列表
  def SpiritRoomV1APIHelper.product_list(customerUser)

    spiritRoom = SpiritRoom.where({'customer_id' => customerUser.id}).first
    return {msg: '当前会员未开通酒库,请开通后进行认领!', flag: 2} if !spiritRoom.present?

    spiritRoomProducts = spiritRoom.spirit_room_products.where(:count.gt=>0).order('updated_at desc')

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
  def SpiritRoomV1APIHelper.take_product(customerUser,postInfo)

    spiritRoom = SpiritRoom.where({'customer_id' => customerUser.id}).first
    return {msg: '当前会员未开通酒库,请开通后进行认领!', flag: 2} if !spiritRoom.present?

    s#获取酒库商品信息
    product_info = SpiritRoomV1APIHelper.get_spirit_product_info(spiritRoom)
    product_list = JSON.parse(postInfo.product_list.to_s)

    #检查库存数量是否足够
    product_list.each do |product_id, product_count|
      return {msg: '请移除无效商品!', flag: 0} if !product_info[product_id.to_s].present?
      return {msg: '商品库存不够,请重新选择!', flag: 0} if product_info[product_id.to_s].to_i < product_count.to_i
    end


    {msg: '礼包已发送成功!', flag: 1}
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


end