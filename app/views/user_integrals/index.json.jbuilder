json.array!(@user_integrals) do |user_integral|
  json.extract! user_integral, :id, :integral, :state, :type,:order_no,:integral_no,:integral_date,:cash
  json.url user_integral_url(user_integral, format: :json)
end
