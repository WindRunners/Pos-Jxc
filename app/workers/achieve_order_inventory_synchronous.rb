class AchieveOrderInventorySynchronous

  @queue = :achieve_order_inventory_synchronous

  def self.perform(orderid)

    ordercompleted = Ordercompleted.find(orderid)

    current_user = User.find(ordercompleted['user_id'])
    total_amount = ordercompleted.paycost
    self.generate_sell_out_bill(current_user,total_amount,receivable_amount,bill_detail_array_json)

  end
end