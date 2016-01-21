json.array!(@jxc_sell_exchange_goods_bills) do |jxc_sell_exchange_goods_bill|
  json.extract! jxc_sell_exchange_goods_bill, :id
  json.url jxc_sell_exchange_goods_bill_url(jxc_sell_exchange_goods_bill, format: :json)
end
