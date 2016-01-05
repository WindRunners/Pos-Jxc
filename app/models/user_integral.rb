class UserIntegral
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip

  belongs_to :userinfo
  after_initialize :self_no, :if => :new_record?
  after_save do
    if self.state == 1 && self.type==3
      self.userinfo.update(:integral => self.userinfo.integral+self.integral )
    end
  end

  field :usreinfo_id,type: BSON::ObjectId
  field :order_no,type: String
  field :integral_no,type: String
  field :cash,type: Integer, default: 0 # 现金
  field :integral, type: Integer ,default: 0 # 积分
  field :state, type: Integer ,default: 0   # 积分状态  1 入账 2 支出
  field :type, type: Integer ,default: 0    # 积分类型 0 初始入账积分 1 充值入账积分 2 客户反馈积分 3 余额兑换积分 4 绑定积分 5 促销支出
  field :integral_date,type: DateTime

  def state_show_str
    if self.state == 2
      p '支出'
    elsif self.state == 1
      p '入账'
    end
  end

  def type_show_str
    if self.type == 0
      p '初始入账积分'
    elsif self.type ==1
      p '充值入账积分'
    elsif self.type ==2
      p '客户反馈积分'
    elsif self.type ==3
      p '余额兑换积分'
    elsif self.type ==4
      p '绑定积分'
    elsif self.type ==5
      p '商品支出积分'
    end
  end

  def self_no
    time=Time.now
    self.integral_no=time.strftime('%Y%m%d').to_s + time.usec.to_s
    self.integral_date=time
  end

end
