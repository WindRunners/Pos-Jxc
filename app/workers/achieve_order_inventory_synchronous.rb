class AchieveOrderInventorySynchronous

  @queue = :achieve_order_inventory_synchronous

  def self.perform(orderid)

    Rails.logger.info "订单【#{orderid}】同步库存开始"

    ordercompleted = Ordercompleted.find(orderid)

    #同步库存
    return if ordercompleted.is_inventory_syn == 1

    current_user = User.find(ordercompleted['user_id'])
    retail_store = Store.where({'_id' => ordercompleted['store_id']}).first
    total_amount = ordercompleted.totalcost
    receivable_amount = ordercompleted.paycost
    bill_detail_array = []
    ordercompleted.ordergoodcompleteds.each do |ordergoodcompleted|
      bill_detail = {}
      bill_detail['product_id'] = ordergoodcompleted.product_id
      bill_detail['unit'] = ordergoodcompleted.specification
      bill_detail['price'] = ordergoodcompleted.price
      bill_detail['count'] = ordergoodcompleted.quantity
      bill_detail_array << bill_detail
    end

    JxcSellStockOutBill.generate_sell_out_bill(current_user, retail_store, total_amount, receivable_amount, bill_detail_array.to_json)
    #更新库存同步状态
    Ordercompleted.where(:id => orderid).update({'is_inventory_syn' => 1})

    Rails.logger.info "订单【#{orderid}】同步库存结束"
  end
end