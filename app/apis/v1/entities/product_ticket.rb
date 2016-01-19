module Entities
  class ProductTicket < Grape::Entity
    expose :id, documentation: {type: String, desc: '酒券id'}
    expose :title, documentation: {type: String, desc: '标题'}
    expose :start_date, documentation: {type: DateTime, desc: '开始时间'}
    expose :end_date, documentation: {type: DateTime, desc: '结束时间'}
    expose :desc, documentation: {type: String, desc: '分享描述'}
    expose :rule_content, documentation: {type: String, desc: '活动规则'}
    expose :register_customer_count, documentation: {type: Integer, desc: '达到用户注册量'}
    expose :url, documentation: {type: String, desc: '分享链接'}
  end
end