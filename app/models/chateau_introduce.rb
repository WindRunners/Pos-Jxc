class ChateauIntroduce
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  field :introduce, type: String
  belongs_to :chateau,:autosave => true
  belongs_to :Wine,:autosave => true
end