module Entities

  #礼包认领
  class GiftBagClaim < Grape::Entity
    format_with(:iso_timestamp) { |dt| dt.strftime("%Y-%m-%d %H:%M:%S") if dt.present? }
    expose :id, documentation: {type: String, desc: '礼包id'}
    expose :content, documentation: {type: String, desc: '礼包消息'}
    expose :customer_info,documentation: {type: Customer, desc: '小C信息'}
    expose :sign_status,documentation: {type: Integer, desc: '签收状态 -1:过期,0:待签收,1:已签收'}do |giftbag, options|
      giftbag.sign_status = giftbag.expiry_time < Time.now() && giftbag.sign_status == 0  ? -1 : giftbag.sign_status
    end
    with_options(format_with: :iso_timestamp) do
      expose :created_at, documentation: {type: DateTime, desc: '创建时间'}
      expose :expiry_time, documentation: {type: DateTime, desc: '失效时间'}
    end
  end
end