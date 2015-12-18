json.array!(@coupons) do |coupon|
	json.extract! coupon, :id, :title, :quantity, :value, :limit, :startTime, :endTime, :order_amount, :use_goods, :instructions, :created_at, :updated_at, :buy_limit, :aasm_state, :receive_count
	json.products coupon.products, :id, :title, :qrcode, :specification, :price, :category_name, :stock, :sale_count, :avatar_url
end
