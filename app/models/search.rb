class Search
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user

  field :keyword, type: String
  field :hit, type: Integer, default: 0


end