json.array!(@share_integrals) do |share_integral|
  json.extract! share_integral, :id, :title, :start_date, :end_date, :shared_give_integral, :register_give_integral
  json.url share_integral_url(share_integral, format: :json)
end
