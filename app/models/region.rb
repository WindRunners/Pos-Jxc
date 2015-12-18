class Region
  include Mongoid::Document
  include Mongoid::Tree
  field :name, type: String
  has_many :chateaus,autosave:true
end
