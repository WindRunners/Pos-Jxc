require 'grape'

=begin
 公共API,包括(注册,登陆,修改)
=end
class CommonV1API < Grape::API

  desc '小C登录成功回调接口' do
    detail '小C登录成功回调接口 {flag:{0:失败,1:成功},msg:提信息}'
  end
  params do
    requires :customer_id, type: String, desc: '小Cid'
  end
  get 'customer_login_callback' do

    status 200

    current_customerUser

    #分享积分逻辑处理

    #分享酒劵逻辑处理
    {msg: '小C登录回调成功!', flag: 1}
  end

end