module Entities
  class Chateau < Grape::Entity
    expose :id, documentation: {type: String, desc: '酒庄id'}
    expose :name, documentation: {type: String, desc: '标题'}
    expose :logo, documentation: {type: String, desc: 'logo_url'}
  end
end