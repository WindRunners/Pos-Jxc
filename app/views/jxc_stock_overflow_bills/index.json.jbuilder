json.array!(@jxc_stock_overflow_bills) do |jxc_stock_overflow_bill|
  json.extract! jxc_stock_overflow_bill, :id, :bill_no, :customize_bill_no, :overflow_date, :remark, :bill_status
  json.url jxc_stock_overflow_bill_url(jxc_stock_overflow_bill, format: :json)
end
