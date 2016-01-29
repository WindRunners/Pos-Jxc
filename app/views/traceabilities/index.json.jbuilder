json.array!(@traceabilities) do |traceability|
  json.extract! traceability, :id
  json.url traceability_url(traceability, format: :json)
end
