module Entities
  class OrderTrack < Grape::Entity
    format_with(:short_time) {|dt| dt.to_short}

    expose :remarks, documentation: {type: String, desc: '订单状态'}
    with_options(format_with: :short_time) do
      expose :created_at , documentation: {type: String, desc: '时间'}
    end
  end
end


