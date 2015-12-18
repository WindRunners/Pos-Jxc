module Entities
  class Chateau < Grape::Entity
    expose :id, documentation: {type: String, desc: '公告id'}
    expose :name, documentation: {type: String, desc: '标题'}
  end
end