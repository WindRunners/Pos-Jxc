json.array!(@wines) do |wine|
  json.extract! wine, :id, :name, :category, :description, :price, :hits, :sequence, :status, :logo, :ad
  json.url wine_url(wine, format: :json)
end
