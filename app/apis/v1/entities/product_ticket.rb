module Entities
  class ProductTicket < Grape::Entity
    expose :id, documentation: {type: String, desc: '酒券id'}
    expose :title, documentation: {type: String, desc: '标题'}
    expose :desc, documentation: {type: String, desc: '酒券描述'}
    expose :start_date, documentation: {type: DateTime, desc: '酒券开始时间'} do |product_ticket, options|
      product_ticket.start_date = product_ticket.start_date.strftime("%Y-%m-%d %H:%M:%S") if !product_ticket.start_date.nil?
    end
    expose :end_date, documentation: {type: DateTime, desc: '酒券结束时间'}do |product_ticket, options|
      product_ticket.end_date = product_ticket.end_date.strftime("%Y-%m-%d %H:%M:%S") if !product_ticket.end_date.nil?
    end
    expose :desc, documentation: {type: String, desc: '分享描述'}
    expose :rule_content, documentation: {type: String, desc: '活动规则'}
    expose :register_customer_count, documentation: {type: Integer, desc: '达到用户注册量'}
    expose :url, documentation: {type: String, desc: '分享链接'}
    expose :product_id, documentation: {type: String, desc: '商品ID'}
    expose :product_title, documentation: {type: String, desc: '商品名称'}, safe: true
    expose :product_avatar_url, documentation: {type: String, desc: '商品LOGO图片地址'}, safe: true
    expose :product_price, documentation: {type: Integer, desc: '商品价格'}, safe: true
    expose :product_num, documentation: {type: Integer, desc: '商品数量'}, safe: true
  end
end