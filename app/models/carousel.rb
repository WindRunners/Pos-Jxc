class Carousel
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip
  include Mongoid::Geospatial

  belongs_to :user, :foreign_key => :id, :touch => true

  field :area, type: String
  field :start_time, type: DateTime
  field :end_time, type: DateTime
  field :url, type: String

  has_mongoid_attached_file :avatar

  validates_attachment_content_type :avatar, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]
end
