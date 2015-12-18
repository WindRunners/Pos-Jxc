json.array!(@import_bag_receivers) do |import_bag_receiver|
  json.extract! import_bag_receiver, :id, :receiver_mobile, :memo
  json.url import_bag_receiver_url(import_bag_receiver, format: :json)
end
