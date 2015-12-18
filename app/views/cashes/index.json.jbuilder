json.array!(@cashes) do |cash|
  json.extract! cash, :id,:cash,:cash_state,:cash_req_date,:cash_back_date,:userinfo_id,:cash_no,:cash_rno,:cash_name,:cash_email,:pay_email,:pay_name
  json.url cash_url(cash, format: :json)
end
