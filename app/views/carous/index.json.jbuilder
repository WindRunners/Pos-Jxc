json.array!(@carous) do |carou|
  json.extract! carou, :id
  json.url carou_url(carou, format: :json)
end
