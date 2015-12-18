json.array!(@import_bags) do |import_bag|
  json.extract! import_bag, :id, :name, :business_user, :business_mobile, :sender_mobile, :product_list, :price, :expriy_days, :memo
  json.url import_bag_url(import_bag, format: :json)
end
