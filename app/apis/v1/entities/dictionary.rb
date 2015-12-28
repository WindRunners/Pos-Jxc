module Entities
  class Dictionary < Grape::Entity
    expose :name, documentation: {type: String, desc: '名称'}
  end
end