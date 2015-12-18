module Entities
  class City < Grape::Entity
    expose :_id, documentation: {type: String, desc: '小Bid'}
    expose :city, documentation: {type: String, desc: '城市名称'}
  end
end
