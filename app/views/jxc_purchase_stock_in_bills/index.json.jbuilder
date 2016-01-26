json.array!(@jxc_purchase_stock_in_bills) do |jxc_purchase_stock_in_bill|
  json.extract! jxc_purchase_stock_in_bill, :id, :bill_no, :customize_bill_no, :payment_date, :stock_in_date, :current_payment, :remark, :total_amount, :discount, :discount_amount, :payable_amount, :bill_status
  json.url jxc_purchase_stock_in_bill_url(jxc_purchase_stock_in_bill, format: :json)
end
