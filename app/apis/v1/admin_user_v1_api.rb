require 'grape'

class AdminUserV1API < Grape::API
  format :json

  use ApiLogger

  helpers do

    def ahoy
      @ahoy ||= Ahoy::Tracker.new
    end

    def current_user
      token = headers['Authentication-Token']
      @current_user = User.find_by(authentication_token:token)
    rescue
      error!('401 Unauthorized', 401)

    end

    def authenticate!

      error!('401 Unauthorized', 401) unless current_user
    end
  end


  desc '修改密码'
  params do
    requires :mobile, type: String, desc: '手机号'
    requires :code, type: String, desc: '检验码'
    requires :password, type: String, desc: '新密码'
  end
  post 'changepasswd' do
    user = User.find_by(mobile: params[:mobile])

    if user.tmpcode == params[:code]
      user.password = params[:password]
      user.save
    else
      error!("验证码不正确", 202)
    end

  end

  desc '更换手机号', {
      headers: {
          "Authentication-Token" => {
              description: "用户Token",
              required: true
          }
      }
  }
  params do
    requires :code, type: String, desc: '检验码'
    requires :password, type: String, desc: '密码'
    requires :mobile, type: String, desc: '新手机号'
  end
  post 'change_mobile' do
    authenticate!


    if current_user.tmpcode != params[:code]
      error!("验证码不正确", 202)
    end

    error!("密码不正确", 202) unless current_user.valid_password? params[:password]

    @current_user.mobile = params[:mobile]

    if @current_user.save
      {result:'SUCCESS'}
    else
      error!({"message" => @product.errors}, 202)
    end

  end

  desc '根据手机号及检验码向该手机号发送检验码', {
      headers: {
          "Authentication-Token" => {
              description: "用户Token",
              required: true
          }
      }
  }
  params do
    requires :mobile, type: String, desc: '新手机号'
    requires :code, type: String, desc: '检验码'
    optional :type, type: String, desc: '短信设置sms,语音设置voice'
  end
  post 'verifycode' do
    authenticate!

    type = params[:type] || 'sms'
    code = params[:code]

    ChinaSMS.use :yunpian, password: '9525738f52010b28d1b965e347945364'


    if type == 'sms' then # 通用接口
      ChinaSMS.to params[:mobile], '【酒运达】您的验证码是' + code
    else #语音接口
      ChinaSMS.voice params[:mobile], code
    end

    begin
      @current_user.tmpcode=code
      @current_user.save
    rescue
    end

    {message: '验证码已发送，请稍等...'}
  end



end