class Users::SessionsController < Devise::SessionsController
 #before_filter :configure_sign_in_params, only: [:create]
  prepend_before_action :valify_rucaptcha!, only: [:create]
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
    unless params[:user].blank?
      flash.notice = "手机号或密码不正确！"
    end
  end

  # POST /resource/sign_in
  def create

    flash[:mobile]= params[:user][:mobile]

    super

  end

  def valify_rucaptcha!
    if !verify_rucaptcha?
      flash[:mobile]= params[:user][:mobile]
      flash[:rucaptcha_error]="验证码错误"
      redirect_to new_user_session_path and return
    end
    true
  end

  def fix_password

    if params[:setpassword].present?

      @user = User.where(mobile: params[:user][:mobile]).first
      if @user.blank?
        render 'cheak_mobile', layout: false
      else
        if verify_rucaptcha?
          session[:code] = sendMessage(@user.mobile)
          logger.info session[:code]
          render "password_reset", layout: false
        else
          flash[:rucaptcha_error] = "验证码或手机号输入错误"
          render "cheak_mobile", layout: false
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
        render 'devise/sessions/new', layout: false
      else
        flash[:mes_err] = "短信验证码有误"
        render "password_reset", layout: false
      end
      return
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
