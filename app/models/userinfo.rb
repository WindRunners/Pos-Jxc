class Userinfo
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip
  include Mongoid::Geospatial

  has_many :orders
  has_many :ordercompleteds
  has_many :users
  has_many :delivery_users
  has_many :userinfo_asks
  has_many :user_integrals
  has_many :userinfo_oppenids
  has_many :share_integrals
  has_many :product_tickets


  has_and_belongs_to_many :keywords

  has_many :fullReductions
  has_many :promotionDiscounts
  has_many :coupons
  has_many :mobile_categories

  field :name, type: String # 经营者姓名1
  field :idnumber, type: String#身份证号码1

  field :alipay,type: String #支付宝账号
  field :alipay_name,type: String#支付宝姓名

  field :wx_name,type: String,default: "" #微信实名制姓名(即微信绑定银行卡的姓名)
  field :openid,type: String,default: "" #转账唯一标示

  field :address, type: String,default: "" # 经营者地址1
  field :province,type:String ,default: ""  #省1
  field :city,type:String ,default: ""      #市区1
  field :district,type: String ,default: "" #县、区1

  field :shopname, type: String # 经营者商店名称1
  field :location, type: Point, spatial: true, default: []
  field :email, type: String #邮箱 唯一

  field :status, type: Integer,  default: 0 #启用状态，0初始化，1启用，-1禁用1

  field :integral, type: Integer,default: 0 # 积分
  field :approver,type: String #审批人
  field :pusher,type: String #推送人
  field :pusher_phone,type: String #推送人电话
  field :location_data,type: String #周围小B经纬度和配送距离

  # field :cash_pw,type: String #提现密码
  field :work_24,type: String,default: 'false' #24小时店 true／false

  field :alarm_stock, type: Integer,default: 10 # 预警库存数量1

 # field :busp_url, type: String # 营业执照
 # field :footp_url, type: String # 食品流通许可证
 # field :healthp_url, type: String # 卫生许可证
 # field :taxp_url, type: String # 税务登记证
 # field :orgp_url, type: String # 组织机构代码证
 # field :idf_url, type: String # 身份真正面
 # field :idb_url, type: String # 身份证反面
  field :pdistance_state,type: Integer,default: 0  #0/1
  field :pdistance, type: Integer,default: 0 #配送距离
  field :pdistance_ask, type: Integer,default: 0
  field :fright_time,type: String #日间配送时间点
  field :night_time,type: String #夜间配送时间点
  field :fright, type: Integer,default: 0 # 运费
  field :lowestprice, type: Integer,default: 0 # 最低起送价格
  field :h_fright, type: Integer,default: 0 # 运费h
  field :h_lowestprice, type: Integer,default: 0 # 最低起送价格h
  field :start_business, type: String  #营业开始时间
  field :end_business, type: String #营业结束时间
  field :channel_ids, type:Array,default: [] #移动设备推送IDs
  field :role_marks, type:Array,default: [] #角色标识 business: 运营商角色（对运营商），platform：平台角色（对平台）

  validates :province,:city,:email,:pusher_phone, presence: true #名称，种类不能为空
  validates :email,:pusher_phone,uniqueness: true #名称唯一

  index({location: "2d"}, {min: -200, max: 200})

  has_mongoid_attached_file :busp,:default_url => '/missing.png'
  validates_attachment_content_type :busp, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

  has_mongoid_attached_file :footp,:default_url => '/missing.png'
  validates_attachment_content_type :footp, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

  has_mongoid_attached_file :healthp,:default_url => '/missing.png'
  validates_attachment_content_type :healthp, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

  has_mongoid_attached_file :taxp,:default_url => '/missing.png'
  validates_attachment_content_type :taxp, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

  has_mongoid_attached_file :orgp, :default_url => '/missing.png'
  validates_attachment_content_type :orgp, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

  has_mongoid_attached_file :idpf,:default_url => '/missing.png'
  validates_attachment_content_type :idpf, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

  has_mongoid_attached_file :idpb, :default_url => '/missing.png'
  # ,
  #                           :path => "public/upload/image:class/:id/:filename",
  #                           :url => "/upload/image/:class/:id/:basename.:extension"
  validates_attachment_content_type :idpb, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

  #轮播图
  field :img_path1,type: String
  field :img_path2,type: String
  field :url1,type: String
  field :url2,type: String
  field :url3,type: String
  field :url4,type: String

  has_mongoid_attached_file :aseet1, :default_url => '/missing.png',
                            :url => "/upload/image/carousel/:class/:id.:extension",
                            :path => "public:url"
  validates_attachment_content_type :aseet1, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

  has_mongoid_attached_file :aseet2, :default_url => '/missing.png',
                            :url => "/upload/image/carousel/:class/:id.:extension",
                            :path => "public:url"
  validates_attachment_content_type :aseet2, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]



  attr_accessor :lng, :lat

  def integral_update(integral)
    self.update_attributes(:integral => integral) #积分核增
  end
  class << self
    def nearby(coordinate, max_distance=5)
      # 5公里内， 符合条件的记录， 默认取100个。同时会按照距离的远近 进行排序。
      self.geo_near(coordinate).max_distance(max_distance.fdiv   6371).spherical.distance_multiplier(6371000)
    end
  end

end
