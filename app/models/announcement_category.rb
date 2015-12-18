class AnnouncementCategory
  include Mongoid::Document
  include Mongoid::Timestamps
  included Mongoid::Attributes::Dynamic
  field :name, type: String
  field :description, type: String
  validates :name, presence: true, uniqueness: true
  has_many :announcements
end
