class Smslog
  include Mongoid::Document
  include Mongoid::Timestamps

  field :mobile, type: String
  field :code, type: String

  validates :mobile, presence: true
  validates :code, presence: true
end
