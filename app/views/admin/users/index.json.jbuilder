json.array!(@users) do |user|
  json.extract! user, :id, :name, :mobile,:password, :email, :step, :avatar, :audit_desc,:userinfo_id
  json.url admin_user_url(user, format: :json)
end
