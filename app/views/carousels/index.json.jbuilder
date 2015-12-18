json.array!(@carousels) do |carousel|
  json.extract! carousel, :id, :area, :start_time, :end_time, :url
  json.url carousel_url(carousel, format: :json)
end
