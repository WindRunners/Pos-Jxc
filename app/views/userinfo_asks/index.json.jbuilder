json.array!(@userinfo_asks) do |userinfo_ask|
  json.extract! userinfo_ask, :id, :shopname, :approver, :pdistance_state, :pdistance_ask, :ask_date, :rqe_date,:location_data,:location
  json.url userinfo_ask_url(userinfo_ask, format: :json)
end
