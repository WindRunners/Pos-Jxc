json.array!(@orders) do |order|
  json.extract! order, :id, :orderno, :ordertype, :consignee, :address, :telephone
  json.url order_url(order, format: :json)
end
