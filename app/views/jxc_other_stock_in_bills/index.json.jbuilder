json.array!(@jxc_other_stock_in_bills) do |jxc_other_stock_in_bill|
  json.extract! jxc_other_stock_in_bill, :id, :bill_no, :customize_bill_no, :stock_in_date, :stock_in_type, :remark, :bill_status
  json.url jxc_other_stock_in_bill_url(jxc_other_stock_in_bill, format: :json)
end
