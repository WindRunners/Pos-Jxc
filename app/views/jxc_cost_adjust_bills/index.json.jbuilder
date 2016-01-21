json.array!(@jxc_cost_adjust_bills) do |jxc_cost_adjust_bill|
  json.extract! jxc_cost_adjust_bill, :id, :bill_no, :customize_bill_no, :adjust_date, :remark, :bill_status
  json.url jxc_cost_adjust_bill_url(jxc_cost_adjust_bill, format: :json)
end
