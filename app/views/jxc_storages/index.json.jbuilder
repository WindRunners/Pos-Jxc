json.array!(@jxc_storages) do |jxc_storage|
  json.extract! jxc_storage, :id
  json.url jxc_storage_url(jxc_storage, format: :json)
end
