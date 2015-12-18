module Entities

  class GiftBagHis < Grape::Entity
    format_with(:iso_timestamp) { |dt| dt.strftime("%Y-%m-%d %H:%M:%S") if dt.present? }

    expose :id, documentation: {type: String, desc: '礼包id'}
    expose :content, documentation: {type: String, desc: '消息'}
    expose :source_mark, documentation: {type: Integer, desc: '礼包来源标识0:送出礼包,1:收到礼包'}
    expose :customer_info, documentation: {type: Customer, desc: '小C信息'}
    with_options(format_with: :iso_timestamp) do
      expose :updated_at, documentation: {type: DateTime, desc: '更新时间'}
    end
  end
end
