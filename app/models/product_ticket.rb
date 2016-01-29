class ProductTicket
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  include Mongoid::Paperclip
  field :title, type: String
  field :start_date, type: DateTime
  field :end_date, type: DateTime
  field :product_id, type: String
  field :status, type: Integer,default: 0 #0，未发布1，已发布
  field :desc, type: String
  field :rule_content, type: String
  field :customer_ids, type: Array,default: []
  field :register_customer_count, type: Integer,default: 1
  field :login_customer_count, type: Integer,default: 1


  #LOGO图片
  has_mongoid_attached_file :logo,
                            :default_url => '/missing.png'
  validates_attachment_content_type :logo, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]
  #第三方页面banner图片
  has_mongoid_attached_file :banner,
                            :default_url => '/missing.png'
  validates_attachment_content_type :banner, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

  validates :title, presence: true #名称，种类不能为空
  validates :title,uniqueness: true #名称唯一

  has_many :share_integral_records
  has_many :card_bags
  belongs_to :userinfo


  def start_date_str
    start_date.strftime("%Y-%m-%d %H:%M:%S")
  end



  def end_date_str
    end_date.strftime("%Y-%m-%d %H:%M:%S")
  end



  def status_str
    if self.status == 0
      p '未发布'
    else
      p '已发布'
    end
  end
end
