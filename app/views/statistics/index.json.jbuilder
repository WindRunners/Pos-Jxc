json.array!(@statistics) do |statistic|
  json.extract! statistic, :qrcode, :purchasePrice, :retailPrice, :quantity
  json.url statistic_url(statistic, format: :json)
end
