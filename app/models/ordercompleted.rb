class Ordercompleted
  include Wisper::Publisher
  include Mongoid::Document
  include Mongoid::Timestamps
  include Workflow
  include Mongoid::Geospatial
  include Mongoid::Attributes::Dynamic

  belongs_to :userinfo
  belongs_to :delivery_user
  has_many :ordergoodcompleteds,:autosave => true
  has_many :order_tracks

  field :customer_id                 #个人用户ID
  field :orderno, type: String      #订单号码
  field :ordertype, type: Integer    #订单类型  0-线下订单  1-线上订单
  field :consignee, type: String, default: ''    #收货人
  field :address, type: String, default: ''    #收货人地址
  field :location, type: Point, spatial: true, default: []
  field :telephone, type: String, default: ''     #收货电话
  field :useintegral,type: Integer, default: 0   #使用积分数量
  field :getintegral,type: Integer, default: 0   #获赠积分数量
  field :coupon_id, default: ""   #优惠券id
  field :totalquantity,type: Integer, default: 0  #商品总数量
  field :totalcost,type: Float, default: 0.00      #总费用
  field :goodsvalue,type: Float, default: 0.00     #总货值
  field :cost_price,type: Float, default: 0.00      #成本价
  field :profit,type: Float, default: 0.00     #利润
  field :fright,type: Float, default: 0.00         #运费
  field :paycost,type: Float, default: 0.00  #支付金额
  field :paymode,type: Integer  #支付方式
  field :online_paid, type: Integer, default: 0 #线上支付 0-未付款 1-已付款 2-已退款 3-酒库提酒
  field :remarks  #备注
  field :getcoupons, type: Array, default: [] #获取的优惠券列表
  field :workflow_state  #付款方式

  field :store_id  # 门店id
  field :distance  # 配送距离
  field :delivery_user_id #配送员id

  workflow do
    state :new do
      event :line_order_creat, :transitions_to => :completed
      event :cancel_order, :transitions_to => :cancelled
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


  #线下订单生成
  def line_order_creat(orderjson)
    products = []
    orderjsonback = OrderJsonBack.new

    current_customer = nil
    if self.customer_id.present?
      current_customer = Customer.find(self.customer_id)
    end

    orderjson["ordergoods"].each do |ordergoodcompleted|
      good = self.ordergoodcompleteds.build(ordergoodcompleted)
      product = good.product
      good.qrcode = product.qrcode
      good.title = product.title
      good.price = product.price
      good.integral = product.integral
      good.specification = product.specification
      good.avatar_url = product.avatar_url

      if product.stock < good.quantity
        products << {"title" => product.title,"stock" => product.stock}
        next
      else
        #计算货值
        self.goodsvalue += good.price * good.quantity
        #库存核销
        product.shop_id(self.userinfo.id).stock_reduce(ordergood.quantity)
        #本次购买积分
        if current_customer != nil
          current_customer.integral += good.integral * good.quantity
          self.user.userinfo.integral -= good.integral * good.quantity
        end
      end
    end

    if products.size > 0
      orderjsonback.state = 601
      orderjsonback.products = products
      return orderjsonback
    end


    #计算总价
    self.totalcost = self.goodsvalue

    if current_customer != nil
      if self.useintegral > 0
        current_customer.integral -= self.useintegral
        self.userinfo.integral += self.useintegral
        self.paycost = self.goodsvalue - self.useintegral * 0.01
      else
        self.paycost = self.goodsvalue
      end
      current_customer.update_attributes(:integral => current_customer.integral)
    else
      self.paycost = self.goodsvalue
    end

    time = Time.now
    self.orderno = time.strftime("%Y%m%d%H%M%S") + time.usec.to_s

    success = true
    retailDate = time.strftime("%Y-%m-%d")
    self.ordergoodscompleteds.each do |og|
      statistic = Statistic.new(:retailDate => retailDate)
      statistic.qrcode = og.qrcode
      statistic.productName = og.title
      statistic.purchasePrice = og.product.purchasePrice
      statistic.retailPrice = og.price
      statistic.quantity = og.quantity
      success &= statistic.save
    end

    return success

  end



  def self.build(order)
    ordercompleted = Ordercompleted.new(:id => order.id,
                                        :userinfo => order.userinfo,
                                        :customer_id => order.customer_id,
                                        :orderno => order.orderno,
                                        :ordertype => order.ordertype,
                                        :consignee => order.consignee,
                                        :address => order.address,
                                        :location => order.location,
                                        :telephone => order.telephone,
                                        :useintegral => order.useintegral,
                                        :getintegral => order.getintegral,
                                        :coupon_id => order.coupon_id,
                                        :totalquantity => order.totalquantity,
                                        :totalcost => order.totalcost,
                                        :cost_price => order.cost_price,
                                        :goodsvalue => order.goodsvalue,
                                        :profit => order.profit,
                                        :fright => order.fright,
                                        :paycost => order.paycost,
                                        :remarks => order.remarks,
                                        :online_paid => order.online_paid,
                                        :getcoupons => order.getcoupons,
                                        :paymode => order.paymode,
                                        :store_id => order.store_id,
                                        :distance => order.distance,
                                        :delivery_user_id => order.delivery_user_id,
                                        :is_spirit => order.is_spirit
                                         )

    order.ordergoods.each do |ordergood|
      ordercompleted.ordergoodcompleteds.build(:id => ordergood.id,
                                               :product_id => ordergood.product_id,
                                               :qrcode => ordergood.qrcode,
                                               :specification => ordergood.specification,
                                               :title => ordergood.title,
                                               :price => ordergood.price,
                                               :purchasePrice => ordergood.purchasePrice,
                                               :integral => ordergood.integral,
                                               :quantity => ordergood.quantity,
                                               :avatar_url => ordergood.avatar_url,
                                               :is_gift => ordergood.is_gift)
    end
    return ordercompleted
  end

  after_save do
    if self.ordertype == 0
      #写入队列同步总库
      orderjson = (self.to_json(:include => {:ordergoodcompleteds => {:except => :product_id}}).to_s).force_encoding('UTF-8')
      Resque.enqueue(AchieveOrderSynchronous, orderjson)
    else


      #删除未完成订单表中的数据
      Order.find(self.id).destroy
    end

    if "completed" == workflow_state
        subscribe(Statistic.new)
        subscribe(OrderStatistic.new)
        subscribe(StatisticTotal.new)

        broadcast(:completed_order_successful, id.to_s)
      begin
        cashOrder=CashOrder.new
        cashOrder.userinfo_id = self.userinfo.id
        cashOrder.update("orderno"=>self.orderno,"userinfo_id"=>self.userinfo.id,"paycost"=>self.paycost,"pay_state"=>self.paymode,"pay_type"=>1)
      rescue
        cashOrder=CashOrder.new
        cashOrder.update("userinfo_id"=>self.userinfo.id,"orderno"=>self.orderno,"pay_type"=>0)
      end
    end
  end

end
