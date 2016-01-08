class Announcement
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip
  included Mongoid::Attributes::Dynamic

  belongs_to :user
  belongs_to :state
  belongs_to :announcement_category
  has_many :chateau_comments


  field :title, type: String #标题
  field :content, type: String #正文
  field :pic_path, type: Array, default: [] #图片路径
  field :release_time, type: String #第三方发布时间
  field :description, type: String #描述
  field :author, type: String #作者
  field :status, type: Integer, default: 0 #0：默认，1：审核通过，－1:审核不通过
  field :read_num, type: Integer, default: 0 #阅读量
  field :is_top, type: Integer, default: 0 #是否置顶,#0：默认，1：置顶，－1:不置顶
  field :reader, type: Array, default: [] #读者
  field :sequence, type: Integer, default: 0 #排序字段
  field :news_url, type: String #链接
  field :source, type: String #来源
  field :customer_ids, type: Array, default: [] #收藏用户
  field :pic_thumb_path, type: Array, default: [] #缩略图

  has_mongoid_attached_file :avatar,
                            :default_url => '/missing.png'
  validates_attachment_content_type :avatar, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]


  def status_str
    if self.status == 1
      p '通过'
    elsif self.status == 0
      p '待审核'
    elsif self.status == -1
      p '不通过'
    end
  end


  def is_top_str
    if self.is_top == 0
      p '不置顶'
    else
      p '置顶'
    end
  end

  def created_time
    created_at.strftime("%Y%m%d%H%M%S")
  end
end
