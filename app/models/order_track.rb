=begin
订单跟踪表
=end
class OrderTrack
  include Mongoid::Document
  include Mongoid::Timestamps

  field :state, type: String, default: '' #状态
  field :remarks, type: String, default: '' #备注
  field :img_urls,type: Array,default: []

  belongs_to :order #隶属于某个订单
  before_save :set_track_info


  def set_track_info

    state = self.order.current_state.name.to_s
    if state == 'paid'
      self.remarks = "待配送"
    elsif state == 'generation'
      self.remarks = "待付款"
    elsif state=='take'
      self.remarks = "已接单"
    elsif state=='distribution'
      self.remarks = "配送中"
    elsif state=='receive'
      self.remarks = "配送已完成"
    elsif state=='completed'
      self.remarks = "订单已完成"
    elsif state=='cancelled'
      self.remarks = "订单取消"
    end
    self.state = state
  end

end