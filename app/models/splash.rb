class Splash
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip

  field :stop_seconds, type: Integer
  field :start_time, type: DateTime
  field :end_time, type: DateTime

  has_mongoid_attached_file :avatar

  validates_attachment_content_type :avatar, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]
end
