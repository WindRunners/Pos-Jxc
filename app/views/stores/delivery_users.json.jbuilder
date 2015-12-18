json.array!(@delivery_users) do |delivery_users|
  json.extract! delivery_users, :real_name,:mobile
  json.url delivery_user_url(delivery_users, format: :json)
end