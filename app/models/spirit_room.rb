=begin
酒库模型
=end
class SpiritRoom
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  include ActiveModel::SecurePassword

  has_secure_password

  field :password_digest, type: String #密码
  field :customer_id, type: String #会员id
  has_many :spirit_room_products

  index({customer_id: 1}, {unique: true, name: "customer_id_index"}) #小C酒库唯一索引



  #退换酒库商品
  def back_spiritroom_product(order_id)

    order = Order.find(order_id)
    ordergoods = order.ordergoods #订单商品
    spiritRoom = SpiritRoom.where({'customer_id' => order['customer_id']}).first
    userinfo_id = order['userinfo_id'].to_s #小Bid

    ordergoods.each do |ordergood|
        product_id = ordergood.product_id #商品id
        add_spirit_room_product(spiritRoom,userinfo_id,product_id,ordergood.quantity)
        # spiritRoomProduct = SpiritRoomProduct.where(:spirit_room_id => spiritRoom.id, :product_id => product_id, :userinfo_id => userinfo_id).first #酒库商品
        # product = Product.shop_id(userinfo_id).where(id: product_id).first #商品
        #
        # if spiritRoomProduct.present?
        #   spiritRoomProduct.count += ordergood.quantity #累加
        # else
        #   spiritRoomProduct = SpiritRoomProduct.new
        #   spiritRoomProduct['product_id'] = product_id
        #   spiritRoomProduct.count = ordergood.quantity
        #   spiritRoomProduct['userinfo_id'] = userinfo_id
        #   spiritRoomProduct.spirit_room = spiritRoom.id
        #   spiritRoomProduct['mobile_category_name'] = product.category_name
        # end
        # spiritRoomProduct.save! #更新
    end

    #添加酒库日志
    spiritRoomLog = SpiritRoomLog.new
    spiritRoomLog.spirit_room = spiritRoom
    spiritRoomLog['order_id'] = order.id
    spiritRoomLog.remarks = "取消订单商品返回酒库"
    spiritRoomLog.save

  end


  def save_product_ticket_product(product_ticket_id,customer_id)

    product_ticket = ProductTicket.find(product_ticket_id)
    spiritRoom = SpiritRoom.where({'customer_id' => customer_id}).first
    userinfo_id = product_ticket['userinfo_id']
    add_spirit_room_product(spiritRoom,userinfo_id,product_ticket.product_id,1)

    #添加酒库日志
    spiritRoomLog = SpiritRoomLog.new
    spiritRoomLog.spirit_room = spiritRoom
    spiritRoomLog['product_ticket_id'] = product_ticket.id
    spiritRoomLog.remarks = "酒劵分享获得商品"
    spiritRoomLog.save
  end


  private

  #增加酒库商品
  def add_spirit_room_product(spiritRoom,userinfo_id,product_id,count)

    spiritRoomProduct = SpiritRoomProduct.where(:spirit_room_id => spiritRoom.id, :product_id => product_id, :userinfo_id => userinfo_id).first #酒库商品
    product = Product.shop_id(userinfo_id).where(:id => product_id).first #商品
    if spiritRoomProduct.present?
      spiritRoomProduct.count += count #累加
    else
      spiritRoomProduct = SpiritRoomProduct.new
      spiritRoomProduct['product_id'] = product_id
      spiritRoomProduct.count = count
      spiritRoomProduct['userinfo_id'] = userinfo_id
      spiritRoomProduct.spirit_room = spiritRoom.id
      spiritRoomProduct['mobile_category_name'] = product.category_name
    end
    spiritRoomProduct.save! #更新
  end

end