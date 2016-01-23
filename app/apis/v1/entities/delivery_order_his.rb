module Entities

  class DeliveryOrderHis < Grape::Entity
    format_with(:iso_timestamp) { |dt| dt.strftime("%Y-%m-%d %H:%M:%S") if dt.present? }
    expose :id, documentation: {type: String, desc: '订单id'}
    expose :orderno, documentation: {type: String, desc: '订单号'}
    expose :address, documentation: {type: String, desc: '收货人地址'}
    expose :distance, documentation: {type: Float, desc: '配送距离'}do |instance, options|
      instance.distance.present? ?  (instance.distance/1000).round(1) : 0
    end
    expose :workflow_state, documentation: {type: String, desc: '状态 generation:待付款,paid:待抢单,take:待接货,distribution:配送中,receive:配送完成,completed:确认收货,cancelled:取消订单'}
    expose :remarks, documentation: {type: String, desc: '重要说明'} do |instance, options|
        "#{instance.remarks}"
    end

    expose :store_address, documentation: {type: String, desc: '门店地址'}
    with_options(format_with: :iso_timestamp) do
      expose :created_at, documentation: {type: DateTime, desc: '更新时间'}
    end
  end
end
