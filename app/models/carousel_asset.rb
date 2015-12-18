class CarouselAsset
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip

  belongs_to :carousel

  field :img1_path, type: String
  field :img2_path, type: String
  field :url1,type: String
  field :url2,type: String

  has_mongoid_attached_file :asset, :default_url => '/missing.png',
                            :url => "/upload/image/carousel/:class/:id.:extension",
                            :path => "public:url"

  validates_attachment_content_type :asset, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

end
