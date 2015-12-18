json.array!(@stores) do |store|
  json.extract! store, :id, :name, :manager, :describe, :longitude, :latitude, :position,:type
  json.url store_url(store, format: :json)
end
