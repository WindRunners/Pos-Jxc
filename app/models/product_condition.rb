class ProductCondition
  include Mongoid::Document

  field :type, type: String
  field :name, type: String
  field :data


end