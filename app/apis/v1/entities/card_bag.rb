module Entities
  class CardBag < Grape::Entity
    expose :id, documentation: {type: String, desc: '卡包id'}
    expose :product_ticket_id, documentation: {type: String, desc: '酒券id'}
    expose :status, documentation: {type: Integer, desc: '酒券状态'}
  end
end