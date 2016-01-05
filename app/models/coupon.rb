class Coupon
  include Mongoid::Document
  include Mongoid::Timestamps
  include AASM
  
  belongs_to :userinfo, :class_name => "Userinfo", :foreign_key => :userinfo_id
  
  before_create :check
  before_update :check
  
  field :customer_ids, type: Array, default: [] #小Cid列表
  field :product_ids, type: Array, default: [] #商品id列表
  field :full_reduction_ids, type: Array, default: [] #满赠活动id列表
  field :title, type: String #标题
  field :quantity, type: Integer #库存数量
  field :value, type: Float #面值
  field :limit, type: Integer #每人限领
  field :start_time, type: DateTime #开始时间
  field :end_time, type: DateTime #结束时间
  field :order_amount_way, type: String #订单限制方式:0:无限制, 1:看order_amount的值
  field :order_amount, type: Float #订单满多少可使用,order_amount_way = 1才有用
  field :use_goods, type: String #可使用的商品0:全店通用,1:指定商品
  field :instructions, type: String #使用说明
  field :aasm_state, type: String #优惠券状态 noBeging:未开始, beging: 开始, end: 结束
  field :buy_limit, type: Boolean, default: false #购买限制 true:原价购买商品时才能使用, false:不限制
  field :type, type: String
  field :tag, type: String #同步为商品打标签
  field :receive_count, type: Integer, default: 0 #领取次数

  attr_accessor :old_coupon  #旧的对象

  aasm do
    state :noBeging, :initial => true
    state :beging
    state :end
    state :invalided
    
    event :start do
      transitions :from => [:noBeging, :end], :to => :beging
    end

    event :ready do
      transitions :from => [:beging, :end], :to => :noBeging
    end
    
    event :stop do
      transitions :from => [:beging, :noBeging], :to => :end
    end

    event :to_invalid do
      transitions :from => [:beging, :noBeging, :end], :to => :invalided
    end
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

  def changeSelectProducts
    if old_coupon.present?
      old_coupon.product_ids.each do |pid|
        if product_ids.include?(pid)
          old_coupon.product_ids.delete(pid)
        end
      end

      Product.shop_id(userinfo_id.to_s).where(:id => {"$in" => old_coupon.product_ids}).each do |product|
        product.coupon_id = nil
        product.tags_array.delete(old_coupon.tag) if old_coupon.tag.present?
        product.shop_id(userinfo_id.to_s).save
      end
    end
    Product.shop_id(userinfo_id.to_s).where(:id => {"$in" => product_ids}).each do |product|
      if product.coupon_id.blank?
        product.coupon_id = id.to_s
        product.tags_array << tag if tag.present?
      else
        if old_coupon.present? && old_coupon.tag.present?
          if tag.present? && old_coupon.tag != tag
            product.tags_array.delete(old_coupon.tag)
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
    return false if invalided?
    today = Time.now.strftime('%Y%m%d%H%M%S').to_i
    startTime = start_time.strftime('%Y%m%d%H%M%S').to_i
    endTime = end_time.strftime('%Y%m%d%H%M%S').to_i
    
    if today >= startTime && today < endTime
      Rails.logger.info "coupon start======"
      start if may_start?
    elsif today < startTime
      Rails.logger.info "coupon ready======"
      ready if may_ready?
    else
      Rails.logger.info "coupon stop======="
      stop if may_stop?
    end
    changeSelectProducts()
  end
  
  def fullReductions
    result = Array.new
    full_reduction_ids.each.do |fid|
    begin
      result << FullReduction.find(fid)
    rescue
    end
  end
  
  def products
    Product.shop_id(userinfo_id.to_s).where(:id => {"$in" => product_ids})
  end

  def receiveCustomerCount
    customer_ids.size
  end

  def useCount
    Ordercompleted.where(:coupon_id => id.to_s, :userinfo_id => userinfo_id, :workflow_state => "completed").count
  end

  def coupon_format
    couphash = Hash.new
      couphash["coupon_id"] = self.id
      couphash["title"] = self.title
      couphash["value"] = self.value
      couphash["startTime"] = self.start_time.strftime('%Y%m%d%H%M%S')
      couphash["endTime"] = self.end_time.strftime('%Y%m%d%H%M%S')
      couphash["instructions"] = self.instructions

    return couphash.as_json
  end

  class << self
    def getStateDesc(aasm_state)
      case aasm_state
        when "noBeging" then "未开始"
        when "beging" then "正在进行"
        when "end" then "已结束"
        when "invalided" then "已失效"
      end
    end
  end
end
