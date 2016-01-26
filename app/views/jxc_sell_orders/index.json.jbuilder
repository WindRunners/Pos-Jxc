json.array!(@jxc_sell_orders) do |jxc_sell_order|
  json.extract! jxc_sell_order, :id, :order_no, :customize_order_no, :consign_goods_date, :order_date, :receivable_deposit, :remark, :total_amount, :discount, :discount_amount, :receivable_amount, :bill_status
  json.url jxc_sell_order_url(jxc_sell_order, format: :json)
end
