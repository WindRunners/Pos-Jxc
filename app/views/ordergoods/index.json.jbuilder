json.array!(@ordergoods) do |ordergood|
  json.extract! ordergood, :id
  json.url ordergood_url(ordergood, format: :json)
end
