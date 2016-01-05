class FullReduction
  include Mongoid::Document
  include Mongoid::Timestamps
  include AASM
  
  before_create :check
  before_update :check
  before_destroy :clearActivity

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

  field :avatar, type: String, default: "" #活动图片

  attr_accessor :old_full_reduction #旧的对象

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
  
  def clearActivity
    #清除优惠券与满减活动的关联信息
    coupons.each do |c|
      c.full_reduction_ids.delete(id.to_s)
      c.save
    end
    #清除商品与满减活动的关联信息
    participateProducts.each do |p|
      p.full_reduction_id = nil
      p.tags_array.delete(tag)
      p.shop_id(userinfo_id.to_s).save
    end
    #清除赠送商品与满减活动的关联信息
    gifts.each do |p|
      p.gift_full_reduction_ids.delete(id.to_s)
      p.shop_id(userinfo_id.to_s).save
    end
  end

  def changeSelectCouponsProducts
    if old_full_reduction.present?
      case old_full_reduction.preferential_way
        when "3" then
          old_full_reduction.coupon_infos.each do |cinfo|
            if coupon_infos.index {|ci| ci["coupon_id"] == cinfo["coupon_id"]}.present?
              old_full_reduction.coupon_infos.delete(cinfo)
            end
          end
          
          Coupon.where(:id => {"$in" => old_full_reduction.coupon_infos.map {|cinfo| cinfo["coupon_id"]}}).each do |c|
            c.full_reduction_ids.delete(id.to_s)
            c.save
          end
          coupon_infos.each do |cinfo|
            coupon_id = cinfo[:coupon_id] || cinfo["coupon_id"]
            coupon = Coupon.find(coupon_id)
            coupon.full_reduction_ids << id.to_s if !coupon.full_reduction_ids.include?(id.to_s)
            coupon.save
          end

        when "4", "5" then
          old_full_reduction.gifts_product_ids.each do |pinfo|
            if gifts_product_ids.index {|pi| pi["product_id"] == pinfo["product_id"]}.present?
              old_full_reduction.gifts_product_ids.delete(pinfo)
            end
          end

          Product.shop_id(userinfo_id.to_s).where(:id => {"$in" => old_full_reduction.gifts_product_ids.map {|pinfo| pinfo["product_id"]}}).each do |p|
            p.gift_full_reduction_ids.delete(old_full_reduction.id.to_s)
            p.shop_id(userinfo_id.to_s)
          end

          gifts_product_ids.each do |pinfo|
            product_id = pinfo[:product_id] || pinfo["product_id"]
            product = Product.shop_id(userinfo_id.to_s).find(product_id)
            product.gift_full_reduction_ids << id.to_s if !product.gift_full_reduction_ids.include?(id.to_s)
            product.shop_id(userinfo_id.to_s).save
          end
      end

      old_full_reduction.participate_product_ids.each do |pid|
        if participate_product_ids.include?(pid)
          old_full_reduction.participate_product_ids.delete(pid)
        end
      end

      Product.shop_id(userinfo_id.to_s).where(:id => {"$in" => old_full_reduction.participate_product_ids}).each do |p|
        p.full_reduction_id = nil
        p.tags_array.delete(old_full_reduction.tag)
        p.shop_id(userinfo_id.to_s).save
      end
    end

    participateProducts.each do |product|
      if product.full_reduction_id.blank?
        product.tags_array.delete(old_full_reduction.tag) if old_full_reduction.present? && old_full_reduction.tag.present?
        (product.tags.present? ? product.tags_array << tag : product.tags = tag) if tag.present? && !product.tags_array.include?(tag)
        product.full_reduction_id = id.to_s
      else
        if old_full_reduction.present? && old_full_reduction.tag.present?
          if tag.present? && old_full_reduction.tag != tag
            product.tags_array.delete(old_full_reduction.tag)
            product.tags_array << tag
          end
        else
          product.tags_array << tag if tag.present?
        end
      end
      product.shop_id(userinfo_id.to_s).save
    end
  end

  def check
    today = Time.now.strftime('%Y%m%d%H%M%S').to_i
    startTime = start_time.strftime('%Y%m%d%H%M%S').to_i
    endTime = end_time.strftime('%Y%m%d%H%M%S').to_i
    
    if today >= startTime && today < endTime
      Rails.logger.info "full_reduction start======="
      start if may_start?
    elsif today < startTime
      Rails.logger.info "full_reduction ready======="
      ready if may_ready?
    else
      Rails.logger.info "full_reduction stop======="
      stop if may_stop?
    end

    changeSelectCouponsProducts
  end
  
  def coupons
    Coupon.where(:id => {"$in" => coupon_infos.map {|cinfo| cinfo[:coupon_id] || cinfo["coupon_id"]}})
  end
  
  def gifts
    Product.shop_id(userinfo_id.to_s).where(:id => {"$in" => gifts_product_ids.map {|pinfo| pinfo[:product_id] || pinfo["product_id"]}})
  end
  
  def participateProducts
    Product.shop_id(userinfo_id.to_s).where(:id => {"$in" => participate_product_ids})
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
