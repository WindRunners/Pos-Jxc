json.array!(@delivery_users) do |delivery_user|
  json.extract! delivery_user, :id, :real_name, :user_desc, :generate, :scaffold, :DeliveryUser, :real_name, :user_desc, :work_status, :mobile, :login_type, :status, :position
  json.url delivery_user_url(delivery_user, format: :json)
end
