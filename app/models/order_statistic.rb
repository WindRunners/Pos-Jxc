class OrderStatistic
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :userinfo_id, type: String #小B的id
  field :complete_date, type: String #订单完成日期, 格式：2015-12-22
  field :cost_price, type: Float  #订单成本总价
  field :total_price, type: Float #订单成交总价
  field :profit, type: Float #订单利润
  field :order_id, type: String #订单id
  field :customer_id, type: String #小Cid
  field :ordertype, type: String #订单类型  0-线下订单  1-线上订单

  def completed_order_successful(order_id)
    order = Ordercompleted.find(order_id)
    OrderStatistic.create(:userinfo_id => order.userinfo.id.to_s, :complete_date => order.created_at.strftime("%Y-%m-%d"),
                          :cost_price => order.cost_price, :total_price => order.paycost,
                          :profit => order.profit, :order_id => order_id, :customer_id => order.customer_id, :ordertype => order.ordertype)
  end
end
