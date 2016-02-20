class Dictionary
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name
  field :desc
  field :type
  field :subtype
  field :userinfo_id
  def to_s
    name
  end
  validates :name, presence: true, uniqueness: {:scope=> :subtype}
end