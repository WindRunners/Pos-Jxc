=begin
酒库模型
=end
class SpiritRoomLog
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic

  field :remarks, type: String, default: '' #备注

  belongs_to :spirit_room #某个酒库
  belongs_to :gift_bag #隶属于某个礼包
  belongs_to :order #隶属于某个礼包


end