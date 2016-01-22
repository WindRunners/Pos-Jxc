module Entities
  class CardBagList < Grape::Entity
    expose :id, documentation: {type: String, desc: '酒券ID'}
    expose :title, documentation: {type: String, desc: '酒券标题'}
    expose :logo, documentation: {type: String, desc: '酒券logo_url'}
    expose :desc, documentation: {type: String, desc: '酒券描述'}
    expose :url, documentation: {type: String, desc: '分享链接'}
    expose :register_customer_count, documentation: {type: Integer, desc: '酒券领取需要达到的注册用户数'}
    expose :start_date, documentation: {type: DateTime, desc: '酒券开始时间'} do |product_ticket, options|
      product_ticket.start_date = product_ticket.start_date.strftime("%Y-%m-%d %H:%M:%S") if !product_ticket.start_date.nil?
    end
    expose :end_date, documentation: {type: DateTime, desc: '酒券结束时间'}do |product_ticket, options|
      product_ticket.end_date = product_ticket.end_date.strftime("%Y-%m-%d %H:%M:%S") if !product_ticket.end_date.nil?
  end
    expose :status, documentation: {type: String, Integer: '小C卡包内酒券当前状态#0,未失效，1，邀请成功，-1，已失效'}
    expose :product_id, documentation: {type: String, desc: '酒券附赠商品ID'}, safe: true
    expose :product_title, documentation: {type: String, desc: '酒券附赠商品标题'}, safe: true
    expose :product_avatar_url, documentation: {type: String, desc: '酒券附赠商品logo_url'}, safe: true
    expose :product_price, documentation: {type: Integer, desc: '酒券附赠商品价格'}, safe: true
    expose :product_num, documentation: {type: Integer, desc: '酒券附赠商品数量'}, safe: true


  end
end