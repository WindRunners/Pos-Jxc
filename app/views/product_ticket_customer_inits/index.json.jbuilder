json.array!(@product_ticket_customer_inits) do |product_ticket_customer_init|
  json.extract! product_ticket_customer_init, :id, :mobile, :customer_ids
  json.url product_ticket_customer_init_url(product_ticket_customer_init, format: :json)
end
