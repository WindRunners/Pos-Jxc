module Entities

  #礼包认领
  class GiftBagClaim < Grape::Entity
    expose :id, documentation: {type: String, desc: '礼包id'}
    expose :content, documentation: {type: String, desc: '礼包消息'}
    expose :customer_info,documentation: {type: Customer, desc: '小C信息'}
  end
end