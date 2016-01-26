class JxcProductClassifyStandard
  include Mongoid::Document
  include Mongoid::Timestamps

  field :class_name, type: String #类名
  field :standard, type: Integer  #分类标准

  has_many :jxc_storage_product_details
end
