module Entities
  class GiftBagDetail < Grape::Entity
    format_with(:iso_timestamp) { |dt| dt.strftime("%Y-%m-%d %H:%M:%S") if dt.present? }

    expose :flag, documentation: {type: Integer, desc: '标识 1:成功'}
    expose :content, documentation: {type: String, desc: '消息'}
    expose :product_list_info, documentation: {type: Product, desc: '商品列表'},using: Entities::GiftBagProduct
    expose :product_count, documentation: {type: Integer, desc: '商品列表总数'}
    expose :customer_info,documentation: {type: Customer, desc: '小C信息'}

    with_options(format_with: :iso_timestamp) do
      expose :updated_at, documentation: {type: DateTime, desc: '更新时间'}
    end
  end

end