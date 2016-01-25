module Entities
  class AnnouncementCategory < Grape::Entity
    expose :id, documentation: {type: String, desc: '种类id'}
    expose :name, documentation: {type: String, desc: '种类名称'}
    expose :sequence, documentation: {type: Integer, desc: '排序字段'}
  end
end