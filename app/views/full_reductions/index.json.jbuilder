json.array!(@full_reductions) do |full_reduction|
  json.extract! full_reduction, :id, :name, :start_time, :end_time, :preferential_way
  json.url full_reduction_url(full_reduction, format: :json)
end
