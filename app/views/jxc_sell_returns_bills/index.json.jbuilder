json.array!(@jxc_sell_returns_bills) do |jxc_sell_returns_bill|
  json.extract! jxc_sell_returns_bill, :id, :bill_no, :customize_bill_no, :refund_date, :returns_date, :current_refund, :remark, :total_amount, :discount, :discount_amount, :refund_amount, :bill_status
  json.url jxc_sell_returns_bill_url(jxc_sell_returns_bill, format: :json)
end
