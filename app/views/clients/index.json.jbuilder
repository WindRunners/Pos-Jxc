json.array!(@clients) do |client|
  json.extract! client, :id, :name, :jxc_building_user_id
  json.url client_url(client, format: :json)
end
