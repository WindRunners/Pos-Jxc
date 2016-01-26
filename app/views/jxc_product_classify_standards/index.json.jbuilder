json.array!(@jxc_product_classify_standards) do |jxc_product_classify_standard|
  json.extract! jxc_product_classify_standard, :id, :class_name, :standard
  json.url jxc_product_classify_standard_url(jxc_product_classify_standard, format: :json)
end
