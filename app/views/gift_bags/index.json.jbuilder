json.array!(@gift_bags) do |gift_bag|
  json.extract! gift_bag, :id, :receiver_mobile, :sign_status, :expir_days, :expiry_time, :content, :memo
  json.url gift_bag_url(gift_bag, format: :json)
end
