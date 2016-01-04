class ChateauComment
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  field :content, type: String
  field :status, type: Integer, default: 0
  field :hits, type: Integer, default: 0
  field :customer_id, type: String
  belongs_to :chateau, :autosave => true#属于酒庄
  belongs_to :wine
  belongs_to :announcement
end
