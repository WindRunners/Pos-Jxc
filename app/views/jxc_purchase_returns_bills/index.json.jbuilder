json.array!(@jxc_purchase_returns_bills) do |jxc_purchase_returns_bill|
  json.extract! jxc_purchase_returns_bill, :id, :bill_no, :customize_bill_no, :collection_date, :returns_date, :current_collection, :remark, :total_amount, :discount, :discount_amount, :collection_amount, :bill_status
  json.url jxc_purchase_returns_bill_url(jxc_purchase_returns_bill, format: :json)
end
