=begin
酒库模型
=end
class SpiritRoom
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  include ActiveModel::SecurePassword

  has_secure_password

  field :password_digest, type: String #密码
  field :customer_id, type: String #会员id
  has_many :spirit_room_products

  index({customer_id: 1}, {unique: true, name: "customer_id_index"}) #小C酒库唯一索引
end