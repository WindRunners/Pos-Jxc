class FullReduction
  include Mongoid::Document
  include Mongoid::Timestamps
  # include Mongoid::Taggable
  include AASM
  
  before_save :check
  before_update :check

  belongs_to :createUserInfo, :class_name => "Userinfo", :foreign_key => :userinfo_id

  field :purchase_quantity, type: Integer #购买数量
  field :current_quantity, type: Integer,default: 0
  field :ordergoods, type: Array, default: []
  field :use_goods, type: String #0:全部商品，1指定商品
  field :participate_product_ids, type: Array, default: [] #参与的商品列表
  field :gifts_product_ids, type: Array, default: [] #赠送商品列表
  field :coupon_infos, type: Array, default: [] #赠送优惠券列表
  field :name, type: String #活动名称
  field :start_time, type: DateTime #开始时间
  field :end_time, type: DateTime #结束时间
  field :quota, type: Float #满额
  field :reduction, type: Float #减少现金
  field :current_reduction, type: Float,default: 0.0 #减少现金
  field :integral, type: Integer,default: 0 #积分
  field :preferential_way, type: String #优惠方式，1.减现金，2.送积分，3.送优惠券, 4.买赠，5.送赠品
  field :tag, type: String  #标签
  field :aasm_state, type: String #状态
  field :condition, type: Boolean,default: false #是否满足条件

  field :avatar #活动图片

  aasm do
    state :noBeging, :initial => true #未开始
    state :beging #正在进行
    state :end #已结束
    
    event :ready do
      transitions :from => [:beging, :end], :to => :noBeging
    end
    
    event :start do
      transitions :from => [:noBeging, :end], :to => :beging
    end
    
    event :stop do
      transitions :from => [:noBeging, :beging], :to => :end
    end
  end
  
  def url
    "/activities/full_reduction/"
  end
  
  def startTime
    start_time.strftime("%Y%m%d%H%M%S")
  end
  
  def endTime
    end_time.strftime("%Y%m%d%H%M%S")
  end
  
  def startTimeShow
    start_time.strftime("%Y-%m-%d %H:%M")
  end
  
  def endTimeShow
    end_time.strftime("%Y-%m-%d %H:%M")
  end
  
  def couponIds
    coupon_infos.collect {|cinfo| cinfo[:coupon_id]}
  end
  
  def selectCouponHash
    resultHash = Hash.new
    coupon_infos.each {|cinfo| resultHash[cinfo[:coupon_id]] = cinfo[:quantity]}
    resultHash
  end
  
  def selectProductHash
    resultHash = Hash.new
    participate_product_ids.collect {|pid| resultHash[pid] = ""}
    resultHash
  end
  
  def giftSelectProductHash
    resultHash = Hash.new
    gifts_product_ids.collect {|pinfo| resultHash[pinfo[:product_id]] = pinfo[:quantity]}
    resultHash
  end
  
  def giftsProductId
    gifts_product_ids.collect {|pinfo| pinfo[:product_id]}
  end
  
  def products
    Array.new
  end
  
  def groupName
  end
  
  def groupTag
  end
  
  def check
    today = Time.now.strftime('%Y%m%d%H%M%S').to_i
    startTime = start_time.strftime('%Y%m%d%H%M%S').to_i
    endTime = end_time.strftime('%Y%m%d%H%M%S').to_i
    
    if today >= startTime && today < endTime
      start if "beging" != aasm_state
    elsif today < startTime
      ready if "noBeging" != aasm_state
    else
      stop if "end" != aasm_state
    end
  end
  
  def coupons
    result = Array.new
    coupon_infos.each do |cinfo|
      begin
        result << Coupon.find(cinfo[:coupon_id])
      rescue
      end
    end
    result
  end
  
  def giftsById(userInfoId)
    result = Array.new
    gifts_product_ids.each do |pinfo|
      begin
        result << Product.shop_id(userInfoId).find(pinfo[:product_id])
      rescue
      end
    end
    result
  end
  
  def gifts(user)
    result = Array.new
    gifts_product_ids.each do |pinfo|
      begin
        result << Product.shop(user).find(pinfo[:product_id])
      rescue
      end
    end
    result
  end
  
  def participateProductsById(userInfoId)
    result = Array.new
    participate_product_ids.each do |pid|
      begin
        result << Product.shop_id(userInfoId).find(pid)
      rescue
      end
    end
    result
  end
  
  def participateProducts(user)
    result = Array.new
    participate_product_ids.each do |pid|
      begin
        result << Product.shop(user).find(pid)
      rescue
      end
    end
    result
  end

  def gift_good_group
    self.gifts_product_ids.each do |gifts_product_id|
      product = Product.shop_id(self.createUserInfo.id).find(gifts_product_id["product_id"])
      good = Ordergood.new
      good.title = product.title
      good.quantity = gifts_product_id["quantity"].to_i
      good.is_gift = true

      self.ordergoods << good
    end
  end

  class << self
    def getTypeWarehouse(type)
      case type
        when "1" then "full_reduction_cashs"
        when "2" then "full_gift_integrals"
        when "3" then "full_gift_coupons"
        when "4" then "purchase_gift_products"
        when "5" then "full_gift_products"
      end
    end

    def getStateDesc(aasm_state)
      case aasm_state
        when "noBeging" then "未开始"
        when "beging" then "正在进行"
        when "end" then "已结束"
      end
    end
  end
end
