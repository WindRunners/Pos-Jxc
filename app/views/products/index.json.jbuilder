json.array!(@products) do |product|
  json.extract! product, :id, :title, :specification, :qualityday, :description, :avatar
  json.url product_url(product, format: :json)
end
