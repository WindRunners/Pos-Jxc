module Entities
  class CardBagList < Grape::Entity
    expose :id, documentation: {type: String, desc: '酒券ID'}
    expose :title, documentation: {type: String, desc: '酒券标题'}
    expose :logo, documentation: {type: String, desc: '酒券logo_url'}
    expose :register_customer_count, documentation: {type: Integer, desc: '酒券领取需要达到的注册用户数'}
    expose :start_date, documentation: {type: DateTime, desc: '酒券开始时间'}
    expose :end_date, documentation: {type: DateTime, desc: '酒券结束时间'}
    expose :status, documentation: {type: String, Integer: '小C卡包内酒券当前状态#0,未失效，-1，失效'}
    expose :product_id, documentation: {type: String, desc: '酒券附赠商品ID'}, safe: true
    expose :product_title, documentation: {type: String, desc: '酒券附赠商品标题'}, safe: true
    expose :product_avatar_url, documentation: {type: String, desc: '酒券附赠商品logo_url'}, safe: true
    expose :product_price, documentation: {type: Integer, desc: '酒券附赠商品价格'}, safe: true
  end
end