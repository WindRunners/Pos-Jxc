json.array!(@expired_warning_products) do |expired_warning_product|
  json.extract! expired_warning_product, :id
  json.url expired_warning_product_url(expired_warning_product, format: :json)
end
