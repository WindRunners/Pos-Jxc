json.array!(@notices) do |notice|
  json.extract! notice, :id, :title, :content, :is_top,:avatar, :created_at
end
