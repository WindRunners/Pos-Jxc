json.array!(@chateau_comments) do |chateau_comment|
  json.extract! chateau_comment, :id, :content, :status, :hits
  json.url chateau_comment_url(chateau_comment, format: :json)
end
