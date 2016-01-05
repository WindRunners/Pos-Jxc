class DeliveryUser
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  include Mongoid::Geospatial
  resourcify #角色配置
  paginates_per 10 #定义配送员每页显示的条数

  validates :mobile, presence: true, uniqueness: {message: "当前手机号已经注册!"}, format: {with: /\A\d{11}\z/, message: "手机号不合法!"}
  validates :real_name, length: {maximum: 10, too_long: "真实名最大长度为%{count}!"}

  field :real_name, type: String #真实名
  field :user_desc, type: String #用户描述
  field :work_status, type: Integer, default: 0 #工作状态  0:离岗 1:在岗
  field :mobile, type: String #手机号码
  field :authentication_token, type: String #身份认证token
  field :last_login_at, type: DateTime #上一次次登录时间
  field :current_login_at, type: DateTime #当前登录时间
  field :last_login_ip, type: String #上一次登录的ip
  field :current_login_ip, type: String #当前登录的ip
  field :login_count, type: Integer, default: 0 #登陆成功的次数
  field :login_type, type: Integer #登录类型 1:安卓,2:苹果
  field :ios_push_code, type: String #ios 推送编码
  field :android_push_code, type: String #android 推送编码
  field :verify_codes, type: Hash #验证码
  field :status, type: Integer, default: 0 #审核状态 -1:不通过,0:待审核,1:审核通过,2:停用
  field :location, type: Point, spatial: true, default: []
  field :longitude, type: Float #经度
  field :latitude, type: Float #纬度
  field :position, type: String #位置描述
  field :channel_ids, type:Array,default: [] #移动设备推送IDs

  index({mobile: 1}, {unique: true, name: "mobile_index"}) #手机号唯一索引
  index({location: "2d"}, {min: -200, max: 200})

  has_and_belongs_to_many :stores, :autosave => true #负责n个门店

  belongs_to :userinfo #与联盟商关联
  has_many :orders  #关联订单 配送很多个订单
  has_many :ordercompleteds #关联已完成的订单 已经配送完成的订单




#设置配送员登录跟踪信息(时间,ip等)1
  def set_delivery_user_track

    self.authentication_token = JWT.encode({user_id: self.id}, 'key')
    self.last_login_at = self.current_login_at
    self.last_login_ip = self.current_login_ip
    self.current_login_at = Time.now()
    self.login_count +=1
    #self.current_login_ip = request.remote_ip
  end


end
