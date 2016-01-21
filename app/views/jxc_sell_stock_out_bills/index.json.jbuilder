json.array!(@jxc_sell_stock_out_bills) do |jxc_sell_stock_out_bill|
  json.extract! jxc_sell_stock_out_bill, :id, :bill_no, :customize_bill_no, :collection_date, :stock_out_date, :current_collection, :remark, :total_amount, :discount, :discount_amount, :receivable_amount, :bill_status
  json.url jxc_sell_stock_out_bill_url(jxc_sell_stock_out_bill, format: :json)
end
