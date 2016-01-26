json.array!(@jxc_stock_transfer_bills) do |jxc_stock_transfer_bill|
  json.extract! jxc_stock_transfer_bill, :id, :bill_no, :customize_bill_no, :transfer_date, :remark, :transfer_way, :bill_status
  json.url jxc_stock_transfer_bill_url(jxc_stock_transfer_bill, format: :json)
end
