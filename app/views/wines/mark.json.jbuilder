json.array!(@chateau_makes) do |make|
  json.extract! make, :id, :name, :value,
                json.url chateau_url(make, format: :json)
end
