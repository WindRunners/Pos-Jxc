class ChateauMark
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  field :name, type: String
  field :value, type: String

  validates :name, :value, presence: true #名称，属性不能为空
  belongs_to :chateau
  belongs_to :wine,:autosave => true
end