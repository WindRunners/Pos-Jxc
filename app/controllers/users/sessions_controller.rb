class Users::SessionsController < Devise::SessionsController
 #before_filter :configure_sign_in_params, only: [:create]

  #GET /resource/sign_in
  def new
    #super
    # unless params[:user].blank?
    #   flash.notice = "手机号或密码不正确！"
    # end
    respond_to do |format|
      format.html {render layout: false}
      format.json {super}
    end

  end

  # POST /resource/sign_in
  def create

    if params[:setpassword].present?
      @user = User.where(mobile:params[:user][:mobile]).first

      if @user.blank?
        render 'cheak_mobile',layout:false
      else
        if verify_rucaptcha?
          @codestr = [('a'..'z'),('0'..'9')].map{|i| i.to_a}.flatten
          session[:code] = (0..3).map{ @codestr[rand(@codestr.length)] }.join
          sms(@user.mobile,session[:code])
        else
        flash[:rucaptcha_error] = "验证码或手机号输入错误"
        render "cheak_mobile",layout:false
        end
      end
      return
    end

    if params[:change_password].present?
      @user = User.find(params[:id])
      @user.password = params[:user][:password]
      if @user.save && params[:user][:tel]==session[:code]
        session[:_rucaptcha]
        session[:code]=""
        render 'devise/sessions/new',layout:false
      else
        flash[:mes_err] = "短信验证码有误"
        render "password_reset",layout:false
      end
      return
    end

    respond_to do |format|
      # if verify_rucaptcha?
        format.html {super}
        format.json do
          super do |user|
            if params[:user][:channel_id].present?
              user.channel_id = params[:user][:channel_id]
              user.save
            end

            user.name = user.userinfo.name
            user.shop_name = user.userinfo.shopname
          end
        end

        begin
          user = User.find_by(mobile:params[:user][:mobile])
          #创建当前用户的秒杀活动
          if 0 == PanicBuying.where(:userinfo => user.userinfo).count
            PanicBuying.build_panics(user.userinfo)
          end
        end



      # else
      #   format.html {render 'devise/sessions/new', layout: false}
      #   flash[:user_error]='验证码或手机号输入错误'
      # end
    end

  end
  def sms(mobile,code)
    require 'rest_client'
    url = 'http://www.nit.cn:4000'
    url += '/api/v1/user/verifycode'
    begin
      response = RestClient.post(url,:mobile =>"#{mobile}" ,:code=>"#{code}")
      Rails.logger.info "---------========#{response.code}===========----------------"
      if response.code==201
        render "password_reset",layout:false
      else
        flash[:rucaptcha_error] = "短信发送失败"
        render "cheak_mobile",layout:false
        {messages:"短信发送失败"}
      end
    rescue
      flash[:rucaptcha_error] = "短信发送失败"
      render "cheak_mobile",layout:false
      {messages:"短信发送失败"}
    end
  end

  def password_reset
    render layout: false
  end

  def cheak_mobile
    render layout: false
  end
 # DELETE /resource/sign_out
  #  def destroy
  #    super
  #  end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.for(:sign_in) << :attribute
  # end
end
