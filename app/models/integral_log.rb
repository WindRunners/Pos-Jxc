class IntegralLog
  include Mongoid::Document
  include Mongoid::Timestamps

  field :customer_id, type: String #小Cid
  field :quantity, type: Integer #数量（整数：获得、负数：消费）
  field :memo, type: String #备注
  belongs_to :order #隶属于某个订单


  #订单支付成功,设置订单最近门店
  def set_order_integral_log(order_id)

    order = Order.find(order_id)
    if order.workflow_state == 'paid'
      interalLog = IntegralLog.new({'customer_id' => order.customer_id, 'quantity' => -order.useintegral, 'memo' => '消费使用积分'})
    elsif order.workflow_state == 'completed'
      interalLog = IntegralLog.new({'customer_id' => order.customer_id, 'quantity' => order.getintegral, 'memo' => '消费获赠积分'})
    else
      interalLog = IntegralLog.new({'customer_id' => order.customer_id, 'quantity' => order.useintegral, 'memo' => '退换消费积分'})
    end
    interalLog.order = order
    interalLog.save
  end
end