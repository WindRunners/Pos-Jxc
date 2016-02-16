if @jxc_entering_stock.present?
  json.total @jxc_entering_stock.jxc_bill_details.count()
  json.rows do
    json.array!(@jxc_entering_stock.jxc_bill_details) do |j|
      json.title j.product.title
      json.specification j.product.specification
      json.product_id j.product.id
      json.id j.id
      json.(j, :unit, :count, :price, :amount, :remark)
    end
  end
  json.footer do
    json.array! 0...1 do |j|
      json.title "共#{@jxc_entering_stock.jxc_bill_details.count()}条明细"
      json.count @jxc_entering_stock.count(@jxc_entering_stock.jxc_bill_details)
      json.amount @jxc_entering_stock.amount(@jxc_entering_stock.jxc_bill_details)
    end
  end
end
