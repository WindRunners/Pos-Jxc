module Entities
  class DeliveryUser < Grape::Entity

    expose :mobile, documentation: {type: String, desc: '手机号'}
    expose :real_name, documentation: {type: String, desc: '真实名'}
    expose :user_desc, documentation: {type: String, desc: '用户描述'}
    expose :work_status, documentation: {type: Integer, desc: '工作状态  0:离岗 1:在岗'}
    expose :authentication_token, documentation: {type: String, desc: '身份认证token'}
  end
end
