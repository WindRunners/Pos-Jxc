require 'grape'

class OrderV1API < Grape::API
  format :json

  use ApiLogger

  desc '根据商品集合计算支付金额，并且查询该用户可使用的积分' do
    success Entities::OrderJsonBack
  end
  params do
    requires :order, type: String, desc: '{"userinfo_id":"小B的用户id（必填）","customer_id":"小C的用户id（必填）","activities":[{"activitie_id":"非活动可不填","preferential_way":"活动类型（0-无活动,必填）","ordergoods":[{"product_id":"商品id（必填）","quantity":"数量（必填）"},{"product_id":"商品id（必填）","quantity":"数量（必填）"}]},{"activitie_id":"活动id（必填）","preferential_way":"活动类型（必填）","ordergoods":[{"product_id":"商品id（必填）","quantity":"数量（必填）"},{"product_id":"商品id（必填）","quantity":"数量（必填）"}]}]}'
  end
  post 'pay_integral' do
    orderjson = JSON.parse(params[:order])
    params = nil
    orderjsonback = OrderJsonBack.new(:state => 200)
    orderjsonback.activitie_check(orderjson['activities']) #判断活动是否结束
    if 200 == orderjsonback.state
      orderjsonback.stock_check(orderjson["userinfo_id"],false)  #判断商品库存
      if 200 == orderjsonback.state
        order = Order.new(:goodsvalue => 0.00,:totalcost => 0.00,:fright => 0.00,:paycost => 0.00,:useintegral => 0,:activities => [],:coupons => [])
        order.activities = orderjsonback.activities
        act = order.activities.select{|x| x.preferential_way == "0"}[0]
        if act.nil?
          act = FullReduction.new(:preferential_way => "0")
          order.activities << act
        end
        orderjsonback.activities.clear

        order.group_goods   #商品分组（不满足活动作为普通商品）

        current_userinfo = Userinfo.find(orderjson["userinfo_id"])
        order.userinfo = current_userinfo
        if order.goodsvalue < current_userinfo.lowestprice
          order.fright = current_userinfo.fright  #运费
          order.totalcost = order.goodsvalue + order.fright
        else
          order.totalcost = order.goodsvalue
        end
        order.paycost += order.totalcost

        Rails.logger.info "小B查询结束#{current_userinfo}"

        current_customer = Customer.find(orderjson["customer_id"])
        Rails.logger.info "小c查询结果#{current_customer}"
        order.customer_integral = current_customer.integral
        order.customer_id = current_customer.id
        if current_customer.integral > 10
          usecan = (order.totalcost * 0.1 * 100).to_i / 10 * 10  #查询当前订单最多抵扣积分数
          usecan > current_customer.integral ? order.useintegral = (current_customer.integral / 10 * 10) : order.useintegral = usecan
        end
        Rails.logger.info "小c查询结束#{current_customer}"

        if orderjsonback.use_coupon == true
          order.user_coupons
        end
        order.activities = order.activities.as_json(:only => [:_id,:preferential_way,:name,:reduction,:integral,:condition,:ordergoods])
        orderjsonback.order = order
        Rails.logger.info "返回结果#{orderjsonback}"
      end
    end

    present orderjsonback,with: Entities::OrderJsonBack
  end

  desc '随机生成一个订单'
  params do
    requires :id, type: String, desc: '小B的ID'
  end
  get 'generate_order' do

    url = "#{RestConfig::CUSTOMER_SERVER}/v1/customer/registration"

    options = {}

    options['customer'] = {'mobile'=>'18638293566'}.to_json

    response = RestClient.post url, options


    json = JSON.parse(response.body)

    order = {}
    order['userinfo_id'] = params[:id]
    order['customer_id'] = json['id']
    order['consignee'] = Faker::Name.name
    order['address'] = Faker::Address.street_address
    order['telephone'] = Faker::PhoneNumber.cell_phone
    order['paymode'] = 0 #Faker::Number.between(0, 2)
    order['useintegral'] = 0

    ordergoods = []


    products = Product.shop_id(params[:id]).where(:stock.gt => 1).limit(2)

    products.each do |product|

      item = Hash.new

      item['product_id'] = product.id
      item['quantity'] = 1

      ordergoods << item

    end

    order['ordergoods'] = ordergoods

    order['activities'] = []

    order

  end


  desc '根据手机端传过来的参数生成线上订单' do
    success Entities::OrderJsonBack
  end
  params do
    requires :order, type: String, desc: '{"userinfo_id":"小B的用户id（必填）","customer_id":"小C的用户id（必填）","consignee":"收货人（必填）","address":"收获地址（必填）","lat":"经度（必填）","lng":"纬度（必填）","telephone":"联系方式（必填）","useintegral":"使用多少积分（必填）","coupon_id":"优惠券id（可填，默认为空）","paymode":"支付方式（必填；0-货到付款 1-支付宝 2-微信）","remarks":"备注（选填）","activities":[{"activitie_id":"非活动可不填","preferential_way":"活动类型（0-无活动）","ordergoods":[{"product_id":"商品id（必填）","quantity":"数量（必填）"},{"product_id":"商品id（必填）","quantity":"数量（必填）"}]},{"activitie_id":"活动id（必填）","preferential_way":"活动类型（0-无活动）","ordergoods":[{"product_id":"商品id（必填）","quantity":"数量（必填）"},{"product_id":"商品id（必填）","quantity":"数量（必填）"}]}]}'
  end
  post 'online_order_creat' do

    orderjson = JSON.parse(params[:order])   #获取json参数
    params = nil
    orderjsonback = OrderJsonBack.new(:state => 200)
    orderjsonback.activitie_check(orderjson['activities']) #判断活动是否结束
    if 200 == orderjsonback.state
      orderjsonback.stock_check(orderjson["userinfo_id"],true)  #判断商品库存
      if 200 == orderjsonback.state
        order = Order.new(:ordertype => 1,
                          :consignee => orderjson["consignee"],
                          :telephone => orderjson["telephone"],
                          :address => orderjson["address"],
                          :location => [orderjson["lat"],orderjson["lng"]],
                          :useintegral => orderjson["useintegral"],
                          :coupon_id => orderjson["coupon_id"],
                          :paymode => orderjson["paymode"],
                          :remarks => orderjson["remarks"],
                          :userinfo => Userinfo.find(orderjson["userinfo_id"]),
                          :customer_id => orderjson["customer_id"])

        order.online_order(orderjsonback.activities)
        time = Time.now
        order.orderno = time.strftime("%Y%m%d%H%M%S") + time.usec.to_s

        if !order.coupon_id.blank?
          begin
            coupon = Coupon.find(order.coupon_id)
            if coupon.end_time >  DateTime.parse(time.to_s)
              order.paycost -= coupon.value
            else
              orderjsonback.state = 603
              orderjsonback.coupon_id = order.coupon_id
            end
          end
        end

        if orderjsonback.state == 200
          orderjsonback.order = order
          if order.paymode == 0
            order.unpaid!
            # Resque.enqueue_at(2.hours.from_now, AchieveOrderCancelPaid, order.id)
          else
            order.online_order_creat!
            # Resque.enqueue_at(30.minutes.from_now, AchieveOrderSendMessage, order.telephone)
            # Resque.enqueue_at(1.hour.from_now, AchieveOrderCancelGeneration, order.id)
          end
        end
      end
    end

    present orderjsonback,with: Entities::OrderJsonBack

  end



  desc '修改订单的支付方式' do
    success Entities::Order
  end
  params do
    requires :orderid, type: String, desc: '订单id字符串'
    requires :paymode, type: Integer, desc: '支付方式'
  end
  post 'modify_paymode' do
    order = Order.find_by(:id => params[:orderid], :workflow_state => :generation)
    order.paymode = params[:paymode].to_i
    if 0 == order.paymode
      order.unpaid!
    else
      order.update!
    end
    {result:'success'}
  end


  desc '付款成功接口' do
    success Entities::Order
  end
  params do
    requires :orderid, type: String, desc: '订单id字符串'
  end
  post 'payment_order' do
    order = Order.find(params[:orderid])
    if order.payment_order!
      # Resque.enqueue_at(2.hours.from_now, AchieveOrderCancelPaid, order.id)
      present order,with: Entities::Order
    else
      order.errors
    end
  end


  desc 'app取消订单'
  params do
    requires :orderid, type: String, desc: '订单id字符串'
  end
  post 'cancel_order' do
    order = Order.find(params[:orderid])

    if order.cancel_order!
      ordercompleted = Ordercompleted.build(order)
      ordercompleted.cancel_order!

      {result:'success'}
    else
      order.errors
    end
  end



  desc '确认收货后修改订单的状态' do
    success Entities::Ordercompleted
  end
  params do
    requires :orderid, type: String, desc: '订单id字符串'
  end
  post 'confirm_receipt' do
    order = Order.find(params[:orderid])

    if order.commit_order!(false)
      ordercompleted = Ordercompleted.build(order)
      ordercompleted.commit_order!

      {result:'success'}
    else
      order.errors
    end

  end




  desc '查询小C的订单详情' do
    success Entities::Order
  end
  params do
    requires :orderid, type: String, desc: '订单id字符串'
  end
  get 'search_order' do
      order = nil
      begin
        order = Order.find(params[:orderid])
        present order, with: Entities::Order
      rescue
        order = Ordercompleted.find(params[:orderid])
        present order, with: Entities::Ordercompleted
      end
  end



  desc '查询小C的待付款（generation）订单' do
    success Entities::Order
  end
  params do
    requires :customer_id,type: String, desc: '小C的id'
    optional :page, type: Integer, desc: '页码', default: 1
  end
  get 'search_orders_unpaid' do
    orders = Rails.cache.fetch([self, 'search_orders_unpaid']) do
      Order.where(:customer_id => params[:customer_id], :workflow_state => :generation, :ordertype => 1).order(created_at: :desc).page(params[:page]).per(20)
    end
    present orders, with: Entities::Order
  end


  desc '查询小C的已完成（completed）订单' do
    success Entities::Ordercompleted
  end
  params do
    requires :customer_id,type: String, desc: '小C的id'
    optional :page, type: Integer, desc: '页码', default: 1
  end
  get 'search_orders_finish' do
    ordercompleteds = Rails.cache.fetch([self, 'search_orders_finish']) do
      Ordercompleted.where(:customer_id => params[:customer_id], :workflow_state => :completed).order(created_at: :desc).page(params[:page]).per(20)
    end
    present ordercompleteds, with: Entities::Ordercompleted
  end

  desc '查询小C配送完成（receive）订单' do
    success Entities::Order
  end
  params do
    requires :customer_id,type: String, desc: '小C的id'
    optional :page, type: Integer, desc: '页码', default: 1
  end
  get 'search_orders_receive' do
    orders = Rails.cache.fetch([self, 'search_orders_receive']) do
      Order.where(:customer_id => params[:customer_id], :workflow_state => :receive).order(created_at: :desc).page(params[:page]).per(20)
    end
    present orders, with: Entities::Order
  end


  desc '查询小C取消（cancelled）的订单' do
    success Entities::Ordercompleted
  end
  params do
    requires :customer_id,type: String, desc: '小C的id'
    optional :page, type: Integer, desc: '页码', default: 1
  end
  get 'search_orders_cancel' do
    ordercompleteds = Rails.cache.fetch([self, 'search_orders_cancel']) do
      Ordercompleted.where(:customer_id => params[:customer_id], :workflow_state => :cancelled).order(created_at: :desc).page(params[:page]).per(20)
    end
    present ordercompleteds, with: Entities::Ordercompleted
  end



  desc '查询小C配送中（distribution）的订单' do
    success Entities::Order
  end
  params do
    requires :customer_id,type: String, desc: '小C的id'
    optional :page, type: Integer, desc: '页码', default: 1
  end
  get 'search_orders_distribution' do
    orders = Rails.cache.fetch([self, 'search_orders_distribution']) do
       Order.where(:customer_id => params[:customer_id], :workflow_state => :distribution).order(created_at: :desc).page(params[:page]).per(20)
    end
    present orders, with: Entities::Order
  end



  desc '查询小C全部的线上订单' do
    success Entities::Order
  end
  params do
    requires :customer_id,type: String, desc: '小C的id'
    optional :page, type: Integer, desc: '页码', default: 1
  end
  get 'search_orders_all' do

    orders = Rails.cache.fetch([self, 'search_orders_all']) do
      orderarray = []

      complete_ids = []
      uncomplete_ids = []
      orderStateChanges = OrderStateChange.where({:customer_id => params[:customer_id]}).order(created_at: :desc).page(params[:page]).per(20)
      orderStateChanges.each do |orderStateChange|
        if "cancelled" == orderStateChange.state || "completed" == orderStateChange.state
          complete_ids << orderStateChange.id
        else
          uncomplete_ids << orderStateChange.id
        end
      end

      orderarray.concat(Order.where({'_id' => {"$in" => uncomplete_ids}}).order(created_at: :desc)) if !uncomplete_ids.empty?

      if !complete_ids.empty?
        complete_orders = Ordercompleted.where({'_id' => {"$in" => complete_ids}}).order(created_at: :desc)
        complete_orders.each do |ordercompleted|
          ordercompleted['ordergoods'] = ordercompleted.ordergoodcompleteds
          orderarray << ordercompleted
        end
      end

      # orderarray.concat(Ordercompleted.where({'_id' => {"$in" => complete_ids}}).order(created_at: :desc)) if !complete_ids.empty?
      orderarray
    end

    present orders,with: Entities::Order
  end

  desc '查询订单历史状态' do
    success Entities::OrderTrack
  end
  params do
    requires :orderid, type: String, desc: '订单ID'
  end
  get 'order_track' do

    order_tracks = OrderTrack.where(order_id:params[:orderid])
    present order_tracks, with: Entities::OrderTrack

  end


  desc '催单接口' do
    detail '返回结果:{flag:(1:成功,0:失败),msg:提示信息}'
  end
  params do
    requires :orderid, type: String, desc: '订单ID'
  end
  get 'reminder' do

    order = Order.where({"_id" => BSON::ObjectId(params[:orderid])}).first()
    if order.present? && order.workflow_state == 'paid'
      channels = []
      dusers = DeliveryUser.where(:store_ids => order.store_id)
      dusers.each do |user|
        channels.concat user.channel_ids if user.channel_ids.present?
      end
      push_log = PushLog.create(:order_id => params[:orderid], :userinfo_id => order['userinfo_id'])
      Resque.enqueue(AchieveOrderPushChannels, channels, 0, push_log.id)
      return {'flag'=>1,'msg'=>'催单成功，请耐心等待！'}
    else
      return {'flag'=>1,'msg'=>'当前订单已处理，请耐心等待！'}
    end
  end
  
end