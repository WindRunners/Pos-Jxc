class Wine
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  include Mongoid::Paperclip

  field :name, type: String
  field :category, type: Integer#1白酒  2啤酒 3葡萄酒 4洋酒 5黄酒 6养生酒 7收藏酒 8陈年老酒
  field :ad, type: String
  field :description, type: String
  field :price, type: Integer,default: 0 #1:100元以下2:101-200元3:201-300元4:301-500元5:501-1000元6:1001-3000元7:3001-5000元8:5001-10000元9:10000元以上
  field :hits, type: Integer,default: 0 #排序字段
  field :sequence, type: Integer,default: 0 #排序字段
  field :status, type: Integer, default: 0 #0：默认，1：审核通过，－1:审核不通过
  #LOGO图片
  has_mongoid_attached_file :logo,styles: { thumb: "200x200>" },
                            :default_url => '/missing.png'
  validates_attachment_content_type :logo, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

  validates :name, :category, presence: true #名称，种类不能为空

  has_one :chateau_introduce, :autosave => true # 详细介绍
  has_many :pictures #轮播图片
  has_many :chateau_marks #标签
  belongs_to :chateau, :autosave => true#所属酒庄
  belongs_to :user, :autosave => true#上传人



  def created_time
    created_at.strftime("%Y%m%d%H%M%S")
  end
end
