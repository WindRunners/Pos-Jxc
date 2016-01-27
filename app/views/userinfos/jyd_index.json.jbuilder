json.array!(@userinfos) do |userinfo|
  json.extract! userinfo, :id, :name, :address, :shopname,:location, :lng, :lat, :pdistance,:busp, :footp,:healthp, :taxp, :orgp, :idpf, :idpb, :city
  json.url userinfo_url(userinfo, format: :json)
end
