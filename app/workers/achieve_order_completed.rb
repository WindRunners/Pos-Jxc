class AchieveOrderCompleted

  @queue = :achieves_queue_completed

  def self.perform(orderid)

    begin

      order = Order.find(orderid)
      if :receive == order.load_workflow_state.to_sym
        #自动确认收货
        if order.commit_order!
          ordercompleted = Ordercompleted.build(order)
          ordercompleted.commit_order!(true)
        else
          order.errors
        end
      end
    rescue

    end
  end
end