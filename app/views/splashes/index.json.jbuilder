json.array!(@splashes) do |splash|
  json.extract! splash, :id
  json.url splash_url(splash, format: :json)
end
