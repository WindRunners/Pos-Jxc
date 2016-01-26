json.array!(@jxc_purchase_exchange_goods_bills) do |jxc_purchase_exchange_goods_bill|
  json.extract! jxc_purchase_exchange_goods_bill, :id
  json.url jxc_purchase_exchange_goods_bill_url(jxc_purchase_exchange_goods_bill, format: :json)
end
