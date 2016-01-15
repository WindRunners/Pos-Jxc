module Entities
  class ShareIntegral < Grape::Entity
    expose :title, documentation: {type: String, desc: '分享链接标题'}
    expose :desc, documentation: {type: String, desc: '分享链接描述'}
    expose :shared_give_integral, documentation: {type: Integer, desc: '分享赠送积分'}
    expose :register_give_integral, documentation: {type: Integer, desc: '注册赠送积分'}
    expose :logo, documentation: {type: String, desc: '分享链接Logo图片url'}
    expose :share_app_pic, documentation: {type: String, desc: '分享页面主图url'}
    expose :share_url, documentation: {type: String, desc: '分享的url'}
  end

end