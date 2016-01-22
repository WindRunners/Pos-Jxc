require 'grape'
require 'helpers/regex_v1_api_helper'

class UserFeedbackV1API < Grape::API
  format :json


  #需要身份验证的接口
  resource do
    #路由之前身份认证
    before do
      authenticate_deliveryUser
      status 200 #修改post默认返回状态
    end

    desc '添加用户建议反馈'
    params do
      requires :token, type: String, desc: '身份认证token'
      # requires :mobile, type: String, desc: '手机号'
      # requires :real_name, type: String, desc: '真实名'
      requires :feedback_content, type: String, desc: '建议反馈内容'
    end
    post 'add_feedback' do
      current_deliveryUser

      mobile = params[:mobile]
      real_name = params[:real_name]
      feedback_content = params[:feedback_content]
      return {msg: '手机号不合法!', flag: 0} if !RegexV1APIHelper.mobile(mobile)

      feedback = current_deliveryUser.feedbacks.build(mobile: mobile, real_name: real_name, feedback_content: feedback_content)
      if feedback.save
        {msg: "用户反馈成功!", flag: 1}
      else
        {msg: "用户反馈失败!", flag: 0}
      end
    end

  end

end