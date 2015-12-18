=begin
后台导入礼包接受者
=end
class ImportBagReceiver
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic

  paginates_per 10 #定义配送员每页显示的条数

  validates :receiver_mobile, presence: true, format: {with: /\A\d{11}\z/, message: "手机号不合法!"}
  validates :memo, length: {maximum: 100, too_long: "备注最大长度为%{count}"}

  field :receiver_mobile, type: String #接受者手机号
  field :memo, type: String #备注

  belongs_to :import_bag #关联导入礼包
  has_one :gift_bag #如果审核通过的话,有一个发送礼包

  index({receiver_mobile: 1, import_bag_id: 1}, {unique: true, name: "import_bag_mobile_index"}) #导入礼包手机号唯一索引
end