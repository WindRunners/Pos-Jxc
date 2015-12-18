json.array!(@panic_buyings) do |panic_buying|
  json.extract! panic_buying, :id, :panic_price, :cycle, :beginTime, :endTime
  json.url panic_buying_url(panic_buying, format: :json)
end
