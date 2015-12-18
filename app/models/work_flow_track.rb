=begin
  工作流跟踪模型
=end
class WorkFlowTrack
  include Mongoid::Document
  include Mongoid::Timestamps

  field :state, type: String #节点
  field :event, type: String #事件
  field :memo, type: String #备注

  belongs_to :user #隶属于某个操作用户
  belongs_to :import_bag #隶属于摸一个导入礼包审核
  paginates_per 10 #定义配送员每页显示的条数

end