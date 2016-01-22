class Feedback
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic #动态添加属性
  field :mobile, type: String
  field :real_name, type: String
  field :feedback_content, type: String

  belongs_to :delivery_user
end
