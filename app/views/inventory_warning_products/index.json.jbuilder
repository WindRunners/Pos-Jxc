json.array!(@inventory_warning_products) do |inventory_warning_product|
  json.extract! inventory_warning_product, :id
  json.url inventory_warning_product_url(inventory_warning_product, format: :json)
end
