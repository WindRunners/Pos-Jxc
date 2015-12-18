class AchieveOrderCancelPaid

  @queue = :achieves_queue_cancel_paid

  def self.perform(orderid)
    order = Order.find(orderid)
    if :paid == order.load_workflow_state.to_sym
       #自动取消订单
      if order.cancel_order!
        ordercompleted = Ordercompleted.build(order)
        ordercompleted.cancel_order!
      else
        order.errors
      end
    end
  end
end