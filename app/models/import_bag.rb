=begin
后台导入礼包需要审核
=end
class ImportBag
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  include Workflow
  include ImportBagsHelper

  validate :sender_mobile_must_be_customer

  resourcify #角色配置
  paginates_per 10 #定义配送员每页显示的条数
  validates :name, presence: true,length: { maximum: 100, too_long: "名称最大长度为%{count}" }
  validates :business_user, presence: true,length: { maximum: 20, too_long: "业务员名称最大长度为%{count}" }
  validates :business_mobile, presence: true, format: {with: /\A\d{11}\z/, message: "手机号不合法!"}
  validates :sender_mobile, presence: true, format: {with: /\A\d{11}\z/, message: "手机号不合法!"}
  validates :expiry_days, numericality: { only_integer: true , message: "请输入正整数!"}
  validates :memo, length: { maximum: 100, too_long: "备注最大长度为%{count}" }


  field :name, type: String #礼包名称
  field :business_user, type: String #业务人员名称
  field :business_mobile, type: String #业务人员手机号码
  field :sender_mobile, type: String #发送者手机号码
  field :sender_customer_id, type: String #发送者小C id
  field :product_list, type: Hash #礼包商品{product_id:{name:名称,count:数量,price:价格}}
  field :price, type: Float #礼包价格
  field :expiry_days, type: Integer #过期天数
  field :memo, type: String #备注

  has_many :import_bag_receivers #有很多个接受者
  has_many :work_flow_tracks #有很多个工作流跟踪
  has_many :gift_bags #有很多礼包
  belongs_to :userinfo #隶属于默认运营商
  belongs_to :user #隶属于那个用户作为礼包发起用户

  @@stateHash = {"new"=>"开始","first_check"=>"一级审核","second_check"=>"二级审核"}
  @@eventHash = {"submit"=>"发起审核","cancel"=>"作废","pass"=>"通过","un_pass"=>"不通过"}

  workflow do

    #发起审核
    state :new do
      event :submit, :transitions_to => :first_check
      event :cancel, :transitions_to => :canceled
    end

    #一级审核
    state :first_check do
      event :pass, :transitions_to => :second_check
      event :un_pass, :transitions_to => :new
    end

    #二级审核
    state :second_check do
      event :pass, :transitions_to => :passed
      event :un_pass, :transitions_to => :new
    end

    #通过
    state :passed
    #已经取消的
    state :canceled
  end


  def load_workflow_state
    self[:workflow_state]
  end

  def persist_workflow_state(new_value)
    self[:workflow_state] = new_value
    save!
  end

  #发起
  def submit(current_user,memo)

    save_work_flow_track current_user,memo,'submit'
  end


  #作废
  def cancel(current_user,memo)

    save_work_flow_track current_user,memo,'cancel'
  end


  #通过
  def pass(current_user,memo)

    save_work_flow_track current_user,memo,'pass'
  end


  #不通过
  def un_pass(current_user,memo)

    save_work_flow_track current_user,memo,'un_pass'
  end


  def save_work_flow_track(current_user,memo,event)

    work_flow_track = WorkFlowTrack.new('state'=>self.current_state,'memo'=>memo,'event'=>event)
    work_flow_track.import_bag = self
    work_flow_track.user = current_user
    work_flow_track.save
  end

  def self.get_state_text(state)
    @@stateHash[state]
  end

  def self.get_event_text(event)
    @@eventHash[event]
  end

  #送礼人必须为小C
  def sender_mobile_must_be_customer

    begin

      customer = Customer.find_by_mobile(self.sender_mobile)

      puts "小C为#{customer},手机号为：#{self.sender_mobile}"
      if !customer.present?
        errors.add(:sender_mobile, "送礼人必须为酒运达会员,而且需开通酒库功能,请进行修改!")
      else
        self.sender_customer_id = customer.id.to_s #赋值
      end
    rescue
      errors.add(:sender_mobile, "送礼人必须为酒运达会员,而且需开通酒库功能,请进行修改!")
    end
  end

  after_save do

    #二级审核通过,发送礼包
    if self.current_state.present? && self.current_state.name.to_s == "passed"
      #发送导入礼包
      ImportBagsHelper.sendImportBags(self)
    end
  end

end