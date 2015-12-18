class Keyword
  include Mongoid::Document
  include Mongoid::Timestamps

  has_and_belongs_to_many :userinfos

  field :word, type: String
  field :pinyin, type: String
  field :py, type: String
  field :hit, type: Integer, default: 0


end