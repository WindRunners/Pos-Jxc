json.array!(@promotion_discounts) do |promotion_discount|
  json.extract! promotion_discount, :id, :title, :discount, :type, :participate_product_ids, :aasm_state
  json.url promotion_discount_url(promotion_discount, format: :json)
end
