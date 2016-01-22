json.array!(@card_bags) do |card_bag|
  json.extract! card_bag, :id, :customer_id, :status, :register_customer_count, :login_customer_count, :source
  json.url card_bag_url(card_bag, format: :json)
end
