class Feedback
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic #动态添加属性
  field :mobile, type: String
  field :real_name, type: String
  field :feedback_content, type: String

  validates :real_name, presence: true,length: { maximum: 20, too_long: "最大长度为%{count}个字符" }
  validates :mobile, presence: true, format: {with: /\A\d{11}\z/, message: "不合法!"}
  validates :feedback_content, presence: true
  belongs_to :delivery_user
end
