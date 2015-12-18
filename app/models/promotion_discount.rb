class PromotionDiscount
  include Mongoid::Document
  include Mongoid::Timestamps
  include AASM
  
  belongs_to :createUserInfo, :class_name => "Userinfo", :foreign_key => :userinfo_id
  
  before_save :check
  before_update :check
  
  field :title, type: String
  field :discount, type: Integer #折扣
  field :type, type: String   #0:打折，1:促销
  field :start_time, type: DateTime
  field :end_time, type: DateTime
  field :use_goods, type: String #可使用的商品0:全店通用,1:指定商品
  field :participate_product_ids, type: Array, default: [] #打折格式是品id数组, 促销格式{:product_id => "商品id", :product_name => "商品名称", :price => "促销价格"}
  field :aasm_state, type: String
  field :tag, type: String #标签

  field :avatar #活动图片

  def url
    '/activities/promotion_discount/'
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
  
  def participateProductIds
    result = "0" == type ? participate_product_ids : participate_product_ids.collect {|pinfo| pinfo[:product_id]}
  end
  
  def selectProductHash
    resultHash = Hash.new
    if "0" == type
      participate_product_ids.collect {|pid| resultHash[pid] = ""}
    else
      participate_product_ids.collect {|pinfo| resultHash[pinfo[:product_id]] = pinfo[:price]}
    end
    resultHash
  end
  
  aasm do
    state :noBeging, :initial => true  #未开始
    state :beging  #正在进行
    state :end    #已结束
    
    event :ready do
      transitions :from => [:beging, :end], :to => :noBeging
    end
    
    event :start do
      after do
          startActivity
      end
      transitions :from => [:noBeging, :end], :to => :beging
    end
    
    event :stop do
      after do
          stopActivity
      end
      transitions :from => [:noBeging, :beging], :to => :end
    end
  end

  def startActivity
    Rails.logger.info "startActivity======================"
    participate_product_ids.each do |pid|
      begin
        product = Product.shop_id(createUserInfo.id.to_s).find("0" == type ? pid : pid[:product_id])
        if "0" == type
          panic_price = product.price * discount / (10 <= discount ? 100 : 10) * 10
          Rails.logger.info "panic_price==11111=#{panic_price}"
          panic_price = 0 < panic_price % 10 ? panic_price.to_i + 1 : panic_price
          Rails.logger.info "panic_price==22222=#{panic_price}"
          panic_price /= 10.0
          Rails.logger.info "panic_price==33333=#{panic_price}"
          product.panic_price = panic_price
        else
          product.panic_price = 0 == pid[:price] ? product.price : pid[:price].to_f
        end
        product.shop_id(createUserInfo.id.to_s).save
        # rescue
      end
    end
  end

  def stopActivity
      Rails.logger.info "stopActivity======================"
      products = Product.shop_id(createUserInfo.id.to_s).where(:id => {"$in" => participateProductIds})
      products.each do |p|
          p.panic_price = 0
          Rails.logger.info "p===//id===//#{p.id}"
          p.shop_id(createUserInfo.id.to_s).save
      end
  end
  
  def check
    today = Time.now.strftime('%Y%m%d%H%M%S').to_i
    startTime = start_time.strftime('%Y%m%d%H%M%S').to_i
    endTime = end_time.strftime('%Y%m%d%H%M%S').to_i
    
    if today >= startTime && today < endTime
        Rails.logger.info "start======aasm_state=#{aasm_state}"
        start if "beging" == !aasm_state
        startActivity if "beging" == aasm_state
    elsif today < startTime
        Rails.logger.info "ready======aasm_state=#{aasm_state}"
        ready if "ready" == !aasm_state
    else
        Rails.logger.info "stop=======aasm_state=#{aasm_state}"
        stop if "stop" == !aasm_state
        stopActivity if "stop" == aasm_state
    end
  end
  
  def participateProducts
    result = Array.new
    participate_product_ids.each do |pid|
      begin
        result << Product.shop_id(userinfo_id.to_s).find("0" == type ? pid : pid[:product_id])
      rescue
      end
    end
    result
  end

  class << self
    def getTypeWarehouse(type)
      case type
        when "0" then "discount"
        when "1" then "promotion"
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
