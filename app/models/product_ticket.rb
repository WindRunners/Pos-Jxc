class ProductTicket
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  include Mongoid::Paperclip
  field :title, type: String
  field :start_date, type: DateTime
  field :end_date, type: DateTime
  field :product_id, type: String
  field :status, type: Integer
  field :desc, type: String
  field :rule_content, type: String
  field :customer_ids, type: Array,default: []
  field :register_customer_count, type: Integer,default: 1
  field :login_customer_count, type: Integer,default: 1

  #LOGO图片
  has_mongoid_attached_file :logo,
                            :default_url => '/missing.png'
  validates_attachment_content_type :logo, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

  has_many :share_integral_records
  has_many :card_bags
  belongs_to :userinfo

end
