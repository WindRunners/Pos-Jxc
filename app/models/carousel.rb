class Carousel
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip
  include Mongoid::Geospatial

  belongs_to :user, :foreign_key => :id, :touch => true
  has_many :carouselAssets

  accepts_nested_attributes_for :carouselAssets

  field :area, type: String
  field :start_time, type: DateTime
  field :end_time, type: DateTime
  field :url, type: String
end
