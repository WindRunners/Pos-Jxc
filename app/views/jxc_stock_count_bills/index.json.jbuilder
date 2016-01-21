json.array!(@jxc_stock_count_bills) do |jxc_stock_count_bill|
  json.extract! jxc_stock_count_bill, :id, :bill_no, :customize_bill_no, :check_date, :remark, :bill_status
  json.url jxc_stock_count_bill_url(jxc_stock_count_bill, format: :json)
end
