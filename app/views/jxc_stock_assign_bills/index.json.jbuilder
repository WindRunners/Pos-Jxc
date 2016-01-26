json.array!(@jxc_stock_assign_bills) do |jxc_stock_assign_bill|
  json.extract! jxc_stock_assign_bill, :id
  json.url jxc_stock_assign_bill_url(jxc_stock_assign_bill, format: :json)
end
