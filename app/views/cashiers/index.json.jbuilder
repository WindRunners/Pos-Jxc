json.array!(@cashiers) do |cashier|
  json.extract! cashier, :id, :totalPrice, :discount
  json.url cashier_url(cashier, format: :json)
end
