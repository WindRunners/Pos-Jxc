class PhoneBook
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip
  include Mongoid::Attributes::Dynamic
  belongs_to :creator, :class_name => "User", :touch => true
  field :telephone, type: String
  field :name, type: String
  field :url, type: String
  field :city, type: String
  field :nature, type: String
  field :address, type: String
  has_mongoid_attached_file :photo, :default_url => '/missing.png',
                            :styles => { :small => '200x200>' }

  validates_attachment_content_type :photo, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

end
