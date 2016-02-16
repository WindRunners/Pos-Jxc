json.array!(@phone_books) do |phone_book|
  json.extract! phone_book, :id, :telephone, :name, :url, :city, :nature
  json.url phone_book_url(phone_book, format: :json)
end
