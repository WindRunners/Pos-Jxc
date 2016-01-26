json.array!(@jxc_other_stock_out_bills) do |jxc_other_stock_out_bill|
  json.extract! jxc_other_stock_out_bill, :id, :bill_no, :customize_bill_no, :stock_out_date, :stock_out_type, :remark, :bill_status
  json.url jxc_other_stock_out_bill_url(jxc_other_stock_out_bill, format: :json)
end
