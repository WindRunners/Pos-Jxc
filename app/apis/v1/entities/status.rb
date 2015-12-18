module Entities
  class Status < Grape::Entity
    expose :success, documentation: {type: Boolean, desc: '是否成功,true或false'}
  end
end