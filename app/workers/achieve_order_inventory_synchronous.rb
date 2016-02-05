class AchieveOrderCancelPaid

  @queue = :achieve_order_inventory_synchronous

  def self.perform(orderid)

    order = Ordercompleted.find(orderid)
    if :completed == order.load_workflow_state.to_sym

      #同步库存
    end
  end
end