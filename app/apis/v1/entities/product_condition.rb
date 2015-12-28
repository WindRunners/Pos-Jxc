module Entities
  class ProductCondition < Grape::Entity

    expose :type, documentation: {type: String, desc: '类型'}
    expose :name, documentation: {type: String, desc: '名称'}
    expose :data, documentation: {type: Dictionary, desc: '详细数据'},using: Entities::Dictionary
  end
end