class AchieveOrderCancelGeneration

  @queue = :achieves_queue_cancel_generation

  def self.perform(orderid)
    order = Order.find(orderid)
    if :generation == order.load_workflow_state.to_sym
      if order.cancel_order!
        ordercompleted = Ordercompleted.build(order)
        ordercompleted.cancel_order!
      else
        order.errors
      end
    end
  end
end