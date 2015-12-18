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

end