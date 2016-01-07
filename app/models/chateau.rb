class Chateau
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  include Mongoid::Paperclip

  field :category, type: Integer #1:红酒酒庄 2:白酒酒厂
  field :name, type: String #名字
  field :owner, type: String #所有者
  field :address, type: String #详细地址
  field :phone, type: String #联系电话
  field :urls, type: String #网址
  field :sequence, type: Integer, default: 0 #排序字段
  field :hits, type: Integer #浏览次数
  field :status, type: Integer, default: 0 #0：默认，1：审核通过，－1:审核不通过
  field :pic_path, type: Array #详细图片数组

  validates :name, :category,:region, presence: true #名称，种类不能为空
  validates :name,uniqueness: true #名称唯一

  has_one :chateau_introduce, :autosave => true # 详细介绍
  has_many :pictures #轮播图片
  has_many :chateau_marks #标签
  has_many :wines #名酒
  has_many :chateau_comments , :autosave => true#拥有的评论
  belongs_to :region, :autosave => true#所在地区
  belongs_to :user, :autosave => true#上传人

  #LOGO图片
  has_mongoid_attached_file :logo,
                            :default_url => '/missing.png'
  validates_attachment_content_type :logo, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]


  def created_time
    created_at.strftime("%Y%m%d%H%M%S")
  end

  def status_str
    if self.status == 1
      p '通过'
    elsif self.status == 0
      p '待审核'
    elsif self.status == -1
      p '不通过'
    end
  end
end
