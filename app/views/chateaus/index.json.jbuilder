json.array!(@chateaus) do |chateau|
  json.extract! chateau, :id, :name, :owner, :region,:urls, :logo, :hits, :sequence, :introduce, :pic_path,:address, :phone,
  json.url chateau_url(chateau, format: :json)
end
