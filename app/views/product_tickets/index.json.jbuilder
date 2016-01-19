json.array!(@product_tickets) do |product_ticket|
  json.extract! product_ticket, :id, :title, :start_date, :end_date, :product_id, :status, :desc, :rule_content
  json.url product_ticket_url(product_ticket, format: :json)
end
