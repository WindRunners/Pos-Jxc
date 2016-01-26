json.array!(@jxc_purchase_orders) do |jxc_purchase_order|
  json.extract! jxc_purchase_order, :id, :order_no, :customize_order_no, :receive_goods_date, :order_date, :down_payment, :remark, :total_amount, :discount, :discount_amount, :payable_amount, :bill_status
  json.url jxc_purchase_order_url(jxc_purchase_order, format: :json)
end
