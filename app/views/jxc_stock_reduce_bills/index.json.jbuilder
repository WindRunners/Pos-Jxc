json.array!(@jxc_stock_reduce_bills) do |jxc_stock_reduce_bill|
  json.extract! jxc_stock_reduce_bill, :id, :bill_no, :customize_bill_no, :reduce_date, :remark, :bill_status
  json.url jxc_stock_reduce_bill_url(jxc_stock_reduce_bill, format: :json)
end
