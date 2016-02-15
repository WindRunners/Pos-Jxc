class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip
  include Mongoid::Attributes::Dynamic


  rolify

  after_initialize :set_default_role, :if => :new_record?

  # attr_writer :current_step
  # validates_presence_of :usering_name, :if => lambda { |o| o.current_step == "step1"}
  # validates_presence_of :billing_name, :if => lambda { |o| o.current_step == "step2"}

  attr_accessor :shop_name

  belongs_to :userinfo,:foreign_key => :userinfo_id
  has_one :carousel, :foreign_key => :id

  has_many :products
  has_many :comments
  has_many :announcements

  has_and_belongs_to_many :stores #有多个门店
  has_many :jxc_storages  #有多个仓库

  has_many :searches
  has_many :wines
  has_many :chateaus

  before_save :ensure_authentication_token
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :token_authenticatable,
         :rememberable, :trackable, :validatable, :registerable

  ## Database authenticatable
  field :email, type: String, default: ""
  field :encrypted_password, type: String, default: ""
  field :name, type: String, default: ""
  field :mobile, type: String
  field :authentication_token
  field :tmpcode, type: String,default: "" #临时验证吗
  field :step, type: Integer    #状态  #创建状态1 只能验证邮箱  #创建状态3 只能选择用户角色，上传信息#创建状态9  审核成功
  field :activation_token,type: String#邮箱验证码

  field :audit_desc, type: String #审批备注信息

  field :channel_id #移动设备推送ID
  field :user_flag, type: Integer, default: 0 #用户标识  0为普通用户，1：初始化用户（不可修改和删除）

  #field :admin

  has_mongoid_attached_file :avatar, :default_url => '/images/avatar.png'

  validates_attachment_content_type :avatar, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

  validates :name, presence: true,length: { maximum: 20, too_long: "名称最大长度为%{count}" }
  validates :mobile, presence: true, uniqueness: true,format: {with: /\A\d{11}\z/, message: "手机号不合法!"}
  validates :email, presence: true

  ## Recoverable
  field :reset_password_token, type: String
  field :reset_password_sent_at, type: Time


  ## Rememberable
  field :remember_created_at, type: Time

  ## Trackable
  field :sign_in_count, type: Integer, default: 0
  field :current_sign_in_at, type: Time
  field :last_sign_in_at, type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip, type: String

  ## Confirmable
  field :confirmation_token, type: String
  field :confirmation_token_at, type: Time
  # field :confirmed_at,         type: Time
  # field :confirmation_sent_at, type: Time
  # field :unconfirmed_email,    type: String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, type: Integer, default: 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    type: String # Only if unlock strategy is :email or :both
  # field :locked_at,       type: Time


  ## 进销存
  #采购单
  has_and_belongs_to_many :jxc_purchase_orders
  has_and_belongs_to_many :jxc_purchase_stock_in_bills
  has_and_belongs_to_many :jxc_purchase_returns_bills
  has_and_belongs_to_many :jxc_purchase_exchange_goods_bills
  #销售单
  has_and_belongs_to_many :jxc_sell_orders
  has_and_belongs_to_many :jxc_sell_stock_out_bills
  has_and_belongs_to_many :jxc_sell_returns_bills
  has_and_belongs_to_many :jxc_sell_exchange_goods_bills
  #库存变更单
  has_and_belongs_to_many :jxc_stock_count_bills #盘点单
  has_and_belongs_to_many :jxc_stock_overflow_bills  #报溢单
  has_and_belongs_to_many :jxc_stock_reduce_bills  #报损单
  has_and_belongs_to_many :jxc_stock_transfer_bills  #调拨单
  has_and_belongs_to_many :jxc_stock_assign_bills  #要货单
  #其他出入库单据
  has_and_belongs_to_many :jxc_other_stock_in_bills
  has_and_belongs_to_many :jxc_other_stock_out_bills
  #其他单据
  has_and_belongs_to_many :jxc_cost_adjust_bills #成本调整单

  has_many :jxc_storage_journals  #仓库变更明细中的 创建人

  #addby dfj
 # def send_password_reset
 #   generate_token(:reset_password_token)
 #   self.reset_p#assword_sent_at = Time.zone.now
 #   save!
#
 # end
#
 # def generate_token(column)
 #   begin
 #     self[column] = SecureRandom.urlsafe_base64
 #   end
 # end

  def email_required?
    false
  end

  def to_s
    name + '(' + mobile + ')'
  end

  def shop_id
    if userinfo.present?
      "products#{userinfo.id}"
    else
      "products"
    end

  end

  def as_json(options=nil)
    super(:methods => [:avatar_url, :shop_name])
  end

  def avatar_url
    self.avatar.url
  end

  def set_default_role
    self.add_role :staff

    if self.name == 'Admin'
      self.add_role :admin
    end
  end

  def set_confirmation_token
    self.confirmation_token = generate_authentication_token
    self.confirmation_token_at = Time.now.zone
  end

 # private
 # def generate_authentication_token
 #   loop do
 #     token = Devise.friendly_token
 #     break token unless User.where(authentication_token: token).first
 #   end
 # end#

  def current_step
    @current_step || steps.first
  end

  def steps
    %w[step1 step2 confirmation]
  end

  def next_step
    self.current_step = steps[steps.index(current_step)+1]
  end

  def previous_step
    self.current_step = steps[steps.index(current_step)+1]
  end

  def first_step?
    current_step = steps.first
  end

  def last_step?
    current_step = steps.last
  end

  def all_valid?
    steps.all? do |step|
      self.current_step = step
    end
  end

end
