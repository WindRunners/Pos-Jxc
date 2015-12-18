class Coupon
  include Mongoid::Document
  include Mongoid::Timestamps
  include AASM
  
  belongs_to :userinfo, :class_name => "Userinfo", :foreign_key => :userinfo_id
  
  before_save :check
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
  
  aasm do
    state :noBeging, :initial => true
    state :beging
    state :end
    state :invalided
    
    event :start do
      transitions :from => [:noBeging, :end], :to => :beging
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
  
  def check
    return false if "invalided" == aasm_state
    today = Time.now.strftime('%Y%m%d%H%M%S').to_i
    startTime = start_time.strftime('%Y%m%d%H%M%S').to_i
    endTime = end_time.strftime('%Y%m%d%H%M%S').to_i
    
    if today >= startTime && today < endTime
      puts "start======"
      start if "beging" != aasm_state
    elsif today < startTime
      puts "ready======"
      ready if "noBeging" != aasm_state
    else
      puts "stop======="
      stop if "end" != aasm_state
    end
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
    result = Array.new
    product_ids.each do |pid|
      begin
        result << Product.shop_id(userinfo_id.to_s).find(pid)
      rescue
      end
    end
    result
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
