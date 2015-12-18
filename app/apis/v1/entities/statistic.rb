module Entities
  class Statistic < Grape::Entity
    expose :profit, documentation: {type: Float, desc: '利润'}
    expose :income, documentation: {type: Float, desc: '收入'}
    expose :visitorCount, documentation: {type: Integer, desc: '访客数'}
    expose :watingOrderCount, documentation: {type: Integer, desc: '待接订单数'}
    expose :orderCount, documentation: {type: Integer, desc: '订单数'}
  end
end
