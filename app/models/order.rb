class Order
  include Mongoid::Document
  include Mongoid::Timestamps
  include Workflow
  include Wisper::Publisher
  include Mongoid::Geospatial
  include Mongoid::Attributes::Dynamic

  has_many :order_tracks

  has_many :ordergoods,:autosave => true, :dependent => :destroy
  accepts_nested_attributes_for :ordergoods

  belongs_to :userinfo,:autosave => true
  belongs_to :delivery_user

  field :coupons, type: Array, default: [] #优惠券列表
  field :getcoupons, type: Array, default: [] #获取的优惠券列表
  field :activities, type: Array
  field :customer_id                 #个人用户ID
  field :orderno, type: String      #订单号码
  field :ordertype, type: Integer    #订单类型  0-线下订单  1-线上订单
  field :consignee, type: String, default: ''    #收货人
  field :address, type: String, default: ''    #收货人地址
  field :location, type: Point, spatial: true, default: []
  field :telephone, type: String, default: ''     #收货电话
  field :useintegral,type: Integer, default: 0   #使用积分数量
  field :coupon_id  #优惠券id
  field :customer_integral   #小C总积分
  field :getintegral,type: Integer, default: 0   #获赠积分数量
  field :totalquantity,type: Integer, default: 0  #商品总数量
  field :totalcost,type: Float, default: 0.00      #总费用
  field :cost_price,type: Float, default: 0.00      #成本价
  field :goodsvalue,type: Float, default: 0.00     #总货值
  field :profit,type: Float, default: 0.00     #利润
  field :fright,type: Float, default: 0.00         #运费
  field :paycost,type: Float, default: 0.00  #支付金额
  field :paymode,type: Integer  #支付方式 0-货到付款 1-支付宝 2-微信支付
  field :online_paid, type: Integer, default: 0 #线上支付 0-未付款 1-已付款 2-已退款
  field :remarks  #备注
  field :workflow_state  #

  field :store_id  # 门店id
  field :distance  # 配送距离
  field :delivery_user_id #配送员id
  field :is_spirit, type: Boolean, default: false #是否酒库订单( 酒库订单取消订单后需要商品需要返回酒库)


  index({location: "2d"}, {min: -200, max: 200})

  workflow do
    state :new do
      event :online_order_creat, :transitions_to => :generation
      event :line_order_creat, :transitions_to => :completed
      event :unpaid, :transitions_to => :paid
    end

    # 待付款
    state :generation do
      event :unpaid, :transitions_to => :paid
      event :payment_order, :transitions_to => :paid
      event :cancel_order, :transitions_to => :cancelled
    end

    # 待接单
    state :paid do
      event :receive_order, :transitions_to => :distribution
      event :cancel_order, :transitions_to => :cancelled
      event :take_order, :transitions_to => :take
    end

    # 待接货
    state :take do
      event :take_product, :transitions_to => :distribution
    end

    # 配送中
    state :distribution do
      event :receive_goods, :transitions_to => :receive
      event :commit_order, :transitions_to => :completed
      event :cancel_order, :transitions_to => :cancelled
    end


    # 配送完成
    state :receive do
      event :commit_order, :transitions_to => :completed
    end

    # 已取消
    state :cancelled

    # 已完成
    state :completed
  end


  def load_workflow_state
    self[:workflow_state]
  end

  def persist_workflow_state(new_value)
    self[:workflow_state] = new_value
    save!
  end



  def self.get_all_orders(parm)
    orderarray = []

    orders = Order.where(parm)

    orders.each do |order|
      orderarray << order
    end

    ordercompleteds = Ordercompleted.where(parm)
    ordercompleteds.each do |ordercompleted|
      order = Order.new(ordercompleted.as_json)

      ordercompleted.ordergoodcompleteds.each do |ordergoodcompleted|
        order.ordergoods.build(ordergoodcompleted.as_json(:except => [:ordercompleted_id]))
      end

      orderarray << order
    end

    return orderarray.sort{|a, b| b["created_at"] <=> a["created_at"]}

  end

  def get_gift_product(gifts_product_ids)
    gifts_product_ids.each do |gifts_product_id|
      good = self.ordergoods.build(:product_id => gifts_product_id["product_id"], :quantity => gifts_product_id["quantity"])
      product = good.product
      good.specification = product.specification
      good.qrcode = product.qrcode
      good.title = product.title
      good.avatar_url = product.avatar_url
      good.is_gift = true

      self.totalquantity += good.quantity
    end
  end


  def online_order(activities)
    current_customer = Customer.find(self.customer_id)
    activities.each do |activitie|
      activitie.ordergoods.each do |ordergood|
        self.ordergoods << ordergood

        self.cost_price += ordergood.purchasePrice * ordergood.quantity
        self.goodsvalue += ordergood.price * ordergood.quantity
        self.totalquantity += ordergood.quantity
        self.userinfo.integral -= ordergood.integral * ordergood.quantity

        activitie.current_reduction += ordergood.price * ordergood.quantity
        activitie.current_quantity += ordergood.quantity

        if "1" == activitie.preferential_way || "2" == activitie.preferential_way || "3" == activitie.preferential_way || "5" == activitie.preferential_way
          if activitie.current_reduction >= activitie.quota && (activitie.condition == false)
            activitie.condition = true
            if "1" == activitie.preferential_way
              self.totalcost -= activitie.quota
            elsif "2" == activitie.preferential_way
              self.getintegral += activitie.integral
              self.userinfo.integral -= activitie.integral
            elsif "3" == activitie.preferential_way
              self.getcoupons = activitie.coupon_infos
            elsif "5" == activitie.preferential_way
              self.get_gift_product(activitie.gifts_product_ids)
            end
          end
        elsif "4" == activitie.preferential_way
          if activitie.current_quantity >= activitie.purchase_quantity && (activitie.condition == false)
            activitie.condition = true
            self.get_gift_product(activitie.gifts_product_ids)
          end
        end
      end
    end

    self.profit = self.goodsvalue - self.cost_price
    self.goodsvalue < self.userinfo.lowestprice ? (self.totalcost = self.goodsvalue + self.userinfo.fright; self.fright = self.userinfo.fright) : self.totalcost = self.goodsvalue
    if self.useintegral > 0
      #扣除用户积分
      current_customer.update_attributes(:integral => current_customer.integral - self.useintegral)
      self.paycost = self.totalcost - self.useintegral * 0.01
    else
      self.paycost = self.totalcost
    end
  end



  #接收付款成功信息
  def payment_order
    if self.paymode != 0
      self.online_paid = 1
    end
  end

  #取消订单方法
  def cancel_order
    self.ordergoods.each do |ordergood|
      self.userinfo.integral += ordergood.integral * ordergood.quantity #退还小B积分
    end

    if self.getintegral > 0
      #赠送活动积分
      self.userinfo.integral += self.getintegral #退还小B积分
    end

    #退还用户积分
    if self.useintegral > 0
      current_customer = Customer.find(self.customer_id)
      current_customer.update_attributes(:integral => current_customer.integral + self.useintegral)
    end

    if self.paymode != 0
      if online_paid == 1 #已在线付款
        Resque.enqueue(AchieveOrderRefundOnlinePayment, id)
      end
    end
  end



  #确认收货
  def commit_order(auto)

    #本单购买总积分
    integral_order = 0
    self.ordergoods.each do |ordergood|
      integral_order += ordergood.integral * ordergood.quantity
    end

    if integral_order !=0
      begin
        user_integral=UserIntegral.new
        user_integral.userinfo_id=self.userinfo.id
        user_integral.integral_date=Time.now
        user_integral.order_no=self.orderno
        user_integral.cash=self.paycost
        user_integral.integral=integral_order
        user_integral.state=0
        user_integral.type=5
        user_integral.save
        rescue
      end
    end

    current_customer = Customer.find(self.customer_id)
    if auto == false
      #计算个人本次购买所获积分
      current_customer.integral += integral_order
    end

    if self.getintegral > 0
      #赠送活动积分
      current_customer.integral += self.getintegral
    end
    current_customer.save!

    if !self.getcoupons.empty?
      #赠送优惠券
      url = "http://10.99.99.206:82/api/v1/customer/receiveCoupon"
      headers = {}
      self.getcoupons.each do |coupon_info|
        options = {}
        options['mobile'] = current_customer.mobile
        options['coupon_id'] = coupon_info["coupon_id"]
        options['quantity'] = coupon_info["quantity"].to_i

        options['multipart'] = true
        response = RestClient.post url, options, headers
      end
    end

    #增加小B用户积分
    self.userinfo.integral += self.useintegral if self.useintegral > 0 #积分核增

    if self.userinfo.integral  !=0
      begin
        user_integral=UserIntegral.new
        user_integral.userinfo_id=self.userinfo.id
        user_integral.order_no=self.orderno
        user_integral.integral=self.userinfo.integral
        user_integral.integral_date=Time.now
        user_integral.state=1
        user_integral.type=2
        user_integral.save
      rescue
      end
    end

    #存入统计表
    retailDate = Time.now.strftime("%Y-%m-%d")
    self.ordergoods.each do |og|
      statistic = Statistic.new(:retailDate => retailDate)
      statistic.qrcode = og.qrcode
      statistic.productName = og.title
      statistic.purchasePrice = og.purchasePrice
      statistic.retailPrice = og.price
      statistic.quantity = og.quantity
      statistic.save
    end
  end


  # 判断商品活动是否满足
  def group_goods

    condition_false = []

    self.activities.each do |activitie|
      activitie.ordergoods.each do |ordergood|
        if ordergood.is_gift
          activitie.current_quantity += ordergood.quantity
          self.totalquantity += ordergood.quantity
          next
        end

        activitie.current_reduction += ordergood.price * ordergood.quantity
        activitie.current_quantity += ordergood.quantity
        if "1" == activitie.preferential_way || "2" == activitie.preferential_way || "3" == activitie.preferential_way || "5" == activitie.preferential_way
          if activitie.current_reduction >= activitie.quota && (activitie.condition == false)
            activitie.condition = true
            if "1" == activitie.preferential_way
              self.totalcost -= activitie.quota
            elsif "2" == activitie.preferential_way
              self.getintegral += activitie.integral
            elsif "3" == activitie.preferential_way
              activitie.coupon_infos.each do |coupon_info|
                self.getcoupons << {"title" => Coupon.find(coupon_info["coupon_id"]).title, "quantity" => coupon_info["quantity"].to_i}
              end
            elsif "5" == activitie.preferential_way
              activitie.gift_good_group
            end
          end
        elsif "4" == activitie.preferential_way
          if activitie.current_quantity >= activitie.purchase_quantity && (activitie.condition == false)
            activitie.condition = true
            activitie.gift_good_group
          end
        end

        self.goodsvalue += ordergood.price * ordergood.quantity
        self.totalquantity += ordergood.quantity
      end


      if activitie.condition == false && activitie.preferential_way != "0"
        condition_false << activitie
      end
    end

    if condition_false.size > 0
      condition_false.each do |activitie|
        act = self.activities.select{|x| x.preferential_way == "0"}[0]
        act.ordergoods.concat(activitie.ordergoods)
        self.activities.delete(activitie)
      end
    end
  end

  #小c可使用优惠券列表
  def user_coupons
    coupons = Coupon.where(:userinfo => self.userinfo,:customer_ids => self.customer_id,:end_time.gt => DateTime.parse(Time.now.to_s), :value.lt => self.paycost).order(end_time: :asc) #获取优惠券
    ac = self.activities.select{|x| x.preferential_way == "0"}[0]
    coupons.each do |coupon|
      if "0" == coupon.use_goods
        if "0" == coupon.order_amount_way
          self.coupons << coupon.coupon_format
        else
          if ac.current_reduction >= coupon.order_amount
            self.coupons << coupon.coupon_format
          end
        end
      else
        prototal = 0.00
        coupon.product_ids.each do |proid|
          product_coup = ac.ordergoods.select{|x| x.product_id == proid}
          if product_coup.size > 0
            if "0" == coupon.order_amount_way
              self.coupons << coupon.coupon_format
              break
            else
              prototal += product_coup[0].price * product_coup[0].quantity
              if prototal >= coupon.order_amount
                self.coupons << coupon.coupon_format
              end
            end
          end
        end
      end
    end
    self.paycost -= self.coupons[0]["value"].to_i if self.coupons.size > 0
  end


  before_save do

    #存储订单跟踪表
    state = self.current_state.name.to_s
    #主要用于区分接货操作,接货需要上传图片
    if self['workflow_event']!="take_product" && OrderTrack.where({'order_id' => self.id, 'state' => state}).count == 0

      ordertrack = OrderTrack.new
      ordertrack.order = self
      ordertrack.save
    end

    #移除事件
    self['workflow_event']=nil if self['workflow_event']=="take_product"
  end

  after_save do
    orderjson = (self.to_json(:include => {:ordergoods => {:except => :product_id}}).to_s).force_encoding('UTF-8')
    #同步总库订单表
    Resque.enqueue(AchieveOrderSynchronous, orderjson)

    if workflow_state == 'paid' #待接单状态
      subscribe(OrderNotifier.new)

      broadcast(:order_paid, self.id)

      #设置订单门店
      self.subscribe(Store.new)
      broadcast(:set_order_store,self.id)
    end

  end
end
