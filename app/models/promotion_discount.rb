class PromotionDiscount
  include Mongoid::Document
  include Mongoid::Timestamps
  include AASM
  
  belongs_to :createUserInfo, :class_name => "Userinfo", :foreign_key => :userinfo_id
  
  before_create :check
  before_update :check
  before_destroy :clearActivity
  
  field :title, type: String
  field :discount, type: Integer #折扣
  field :type, type: String   #0:打折，1:促销
  field :start_time, type: DateTime
  field :end_time, type: DateTime
  field :use_goods, type: String #可使用的商品0:全店通用,1:指定商品
  field :participate_product_ids, type: Array, default: [] #打折格式是品id数组, 促销格式{:product_id => "商品id", :product_name => "商品名称", :price => "促销价格"}
  field :aasm_state, type: String
  field :tag, type: String #标签

  field :avatar, type: String, default: "" #活动图片

  attr_accessor :old_promotion_discount  #旧的对象

  validates :title, :type, :start_time, :end_time, :aasm_state, presence: true

  def url
    '/activities/promotion_discount/'
  end

  def createTimeShow
    created_at.strftime("%Y-%m-%d %H:%M")
  end

  def updateTimeShow
    updated_at.strftime("%Y-%m-%d %H:%M")
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
  
  def setParticipateProductIds(selectProductsHash)
    if selectProductsHash.blank? || selectProductsHash.empty?
      self.participate_product_ids.clear
    else
      selectProductIds = selectProductsHash.map {|k, v| k.to_s}

      if "0" == type
        self.participate_product_ids = selectProductIds
      else
        self.participate_product_ids = []
        Product.shop_id(userinfo_id.to_s).where(:id => {"$in" => selectProductIds}).each do |product|
          self.participate_product_ids << {:product_id => product.id.to_s, :product_name => product.title, :price => selectProductsHash[product.id.to_s.to_sym]}
        end
      end
    end
  end

  def participateProductIds
    result = "0" == type ? participate_product_ids : participate_product_ids.collect {|pinfo| pinfo[:product_id] || pinfo["product_id"]}
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

  def changeSelectProducts
    old_participate_product_ids = Array.new
    if old_promotion_discount.present?
      if "0" == type
        old_promotion_discount.participate_product_ids.each do |pid|
          if self.participate_product_ids.include?(pid)
            old_promotion_discount.participate_product_ids.delete(pid)
          end
        end
        old_participate_product_ids = old_promotion_discount.participate_product_ids
      else
        old_promotion_discount.participate_product_ids.each do |pinfo|
          if self.participate_product_ids.index {|pi| pi["product_id"] == pinfo["product_id"]}.present?
            old_promotion_discount.participate_product_ids.delete(pinfo)
          end
        end
        old_participate_product_ids = old_promotion_discount.participate_product_ids.collect {|pinfo| pinfo["product_id"]}
      end

      Product.shop_id(userinfo_id.to_s).where(:id => {"$in" => old_participate_product_ids}).each do |product|
        if product.tags_array.include?(old_promotion_discount.tag)
          product.tags_array.delete(old_promotion_discount.tag)
        end
        product.promotion_discount_id = nil
        product.panic_price = 0
        product.shop_id(userinfo_id.to_s).save
      end

      Product.shop_id(userinfo_id.to_s).where(:id => {"$in" => participateProductIds}).each do |product|
        if product.promotion_discount_id.blank?
          product.tags_array.delete(old_promotion_discount.tag) if old_promotion_discount.present? && old_promotion_discount.tag.present?
          (product.tags.present? ? product.tags_array << tag : product.tags = tag) if tag.present? && !product.tags_array.include?(tag)
          product.promotion_discount_id = id.to_s
        else
          if old_promotion_discount.present? && old_promotion_discount.tag.present?
            if tag.present? && old_promotion_discount.tag != tag
              product.tags_array.delete(old_promotion_discount.tab)
              product.tags_array << tag
            end
          else
            product.tags_array << tag if tag.present?
          end
        end
        product.shop_id(userinfo_id.to_s).save
      end
    end
  end

  def startActivity
    Rails.logger.info "startActivity======================"
    Product.shop_id(userinfo_id.to_s).where(:id => {"$in" => participate_product_ids}).each do |pinfo|
      begin
        product_id = "0" == type ? pinfo : (pinfo[:product_id] || pinfo["product_id"])
        price = pinfo[:price] || pinfo["price"] if "1" == type
        product = Product.shop_id(userinfo_id.to_s).find(product_id)

        if beging?
          if "0" == type
            panic_price = product.price * discount / (10 <= discount ? 100 : 10) * 10
            Rails.logger.info "panic_price==11111=#{panic_price}"
            panic_price = 0 < panic_price % 10 ? panic_price.to_i + 1 : panic_price
            Rails.logger.info "panic_price==22222=#{panic_price}"
            panic_price /= 10.0
            Rails.logger.info "panic_price==33333=#{panic_price}"
            product.panic_price = panic_price
          else
            product.panic_price = 0 == price.to_f ? product.price : price.to_f
          end
        end

        product.shop_id(createUserInfo.id.to_s).save
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

  def clearActivity
    Rails.logger.info "promotion_discount.rb clearActivity == start"
    participateProducts.each do |p|
      p.promotion_discount_id = nil
      p.tags_array.delete(tag)
      p.panic_price = 0
      p.shop_id(userinfo_id.to_s).save
    end
    Rails.logger.info "promotion_discount.rb clearActivity == end"
  end
  
  def check
    Rails.logger.info "promotion_discount-=====check"
    today = Time.now.strftime('%Y%m%d%H%M%S').to_i
    startTime = start_time.strftime('%Y%m%d%H%M%S').to_i
    endTime = end_time.strftime('%Y%m%d%H%M%S').to_i
    
    if today >= startTime && today < endTime
        Rails.logger.info "before_start======aasm_state=#{aasm_state}"
        start if "beging" != aasm_state
        Rails.logger.info "after_start======aasm_state=#{aasm_state}"
        startActivity
    elsif today < startTime
        Rails.logger.info "before_ready======aasm_state=#{aasm_state}"
        ready if "noBeging" != aasm_state
        Rails.logger.info "after_ready======aasm_state=#{aasm_state}"
    else
        Rails.logger.info "before_stop=======aasm_state=#{aasm_state}"
        stop if "end" != aasm_state
        Rails.logger.info "after_stop======aasm_state=#{aasm_state}"
        stopActivity if "end" == aasm_state
    end
    changeSelectProducts
  end
  
  def participateProducts
    products = Product.shop_id(userinfo_id.to_s).where(:id => {"$in" => participateProductIds})
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
