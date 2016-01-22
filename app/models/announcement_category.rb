class AnnouncementCategory
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  field :name, type: String
  field :description, type: String
  field :sequence, type: Integer, default: 0 #排序字段
  validates :name, presence: true, uniqueness: true
  has_many :announcements
end
