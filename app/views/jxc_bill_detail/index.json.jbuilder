json.array!(@jxc_bill_details) do |jxc_bill_detail|
  if jxc_bill_detail.present?
    json.extract! jxc_bill_detail, :id, :unit, :amount, :count,:price, :remark
    json.product do
      json.extract! Warehouse::Product.find(jxc_bill_detail.resource_product_id),:id,:title,:specification
    end
  end
end