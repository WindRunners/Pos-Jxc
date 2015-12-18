module Entities

  class SpiritRoomCategory < Grape::Entity
    expose :id, documentation: {type: String, desc: '类型名'}
    expose :value, documentation: {type: Integer, desc: '类型数量'}
  end

end