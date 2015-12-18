json.array!(@announcements) do |announcement|
  json.extract! announcement, :id, :title, :author, :description, :read_num, :content, :is_top,:avatar,:status,:news_url,:source
  json.url announcement_url(announcement, format: :json)
end
