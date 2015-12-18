module Entities

  class GiftBagProduct < Grape::Entity
    expose :id, documentation: {type: String, desc: '商品id'}
    expose :qrcode, documentation: {type: String, desc: '条码'}
    expose :title, documentation: {type: String, desc: '标题'}
    expose :count, documentation: {type: Integer, desc: '数量'}
    expose :avatar_url, documentation: {type: String, desc: '商品缩略图'}
  end
end