module Entities
  class Wine < Grape::Entity
    expose :id, documentation: {type: String, desc: 'wine_id'}
    expose :name, documentation: {type: String, desc: '名称'}
    expose :logo, documentation: {type: String, desc: 'logo图片地址'}
    expose :hits, documentation: {type: String, desc: '点击数'}
  end
end