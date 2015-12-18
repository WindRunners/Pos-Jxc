json.array!(@dictionaries) do |dictionary|
  json.extract! dictionary, :id, :name, :desc, :type, :subtype
  json.url dictionary_url(dictionary, format: :json)
end
