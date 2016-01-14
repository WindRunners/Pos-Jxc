json.array!(@share_integral_records) do |share_integral_record|
  json.extract! share_integral_record, :id, :shared_customer_id, :register_customer_id, :is_confirm
  json.url share_integral_record_url(share_integral_record, format: :json)
end
