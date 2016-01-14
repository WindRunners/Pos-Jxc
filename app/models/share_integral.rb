class ShareIntegral
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  include Mongoid::Paperclip
  field :title, type: String
  field :start_date, type: DateTime
  field :end_date, type: DateTime
  field :shared_give_integral, type: Integer
  field :register_give_integral, type: Integer
  field :status, type: Integer,default: 0
  field :desc, type: String



  #LOGO图片
  has_mongoid_attached_file :logo,
                            :default_url => '/missing.png'
  validates_attachment_content_type :logo, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

  #app分享页面图片
  has_mongoid_attached_file :share_app_pic,
                            :default_url => '/missing.png'
  validates_attachment_content_type :share_app_pic, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

  #第三方页面分享图片
  has_mongoid_attached_file :share_out_pic,
                            :default_url => '/missing.png'
  validates_attachment_content_type :share_out_pic, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]



  has_many :share_integral_records

  def status_str
    if self.status==0
      p '未启用'
    else
      p '启用'
    end
  end

end
