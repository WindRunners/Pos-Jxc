json.array!(@announcement_categories) do |announcement_category|
  json.extract! announcement_category, :id, :description, :name, :sequence
  json.url announcement_category_url(announcement_category, format: :json)
end
