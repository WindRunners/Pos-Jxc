class Picture
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip
  include Mongoid::Attributes::Dynamic


  field :type, type: Integer#1：轮播图

  belongs_to :chateau
  belongs_to :wine

  has_mongoid_attached_file :pic, styles: { thumb: "640x480>" },
                            :default_url => '/missing.png'
  validates_attachment_content_type :pic, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

end
