class Users::RegistrationsController < Devise::RegistrationsController
 #before_filter :configure_sign_up_params, only: [:create]
 #before_filter :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  def new
   # super
  @user = User.new
  render layout: false
  end

 # POST /resource
  def create
    @user = User.new(user_params)
  #  respond#_to do |format|
  #    if @user.save
  #      UserMailer.signup_confirmation(@user).deliver
  #      @user.update_attribute(:step,1)
  #      format.json{render json:{success:true,token:@user.authentication_token,user_id:@user.id}}
  #    end
  #  end
    @user.userinfo=Userinfo.create(pdistance: 1)
   if @user.save
     # cookies[:authentication_token] = @user.authentication_token
     @user.update(:confirmation_token=>set_confirmation_token,:confirmation_token_at=>Time.now,:step=>1)
     # @user.update_attribute(:confirmation_token,set_confirmation_token)
     # @user.update_attribute(:confirmation_token_at,Time.now)
     # @user.update_attribute(:step,1)
     UserMailer.signup_confirmation(@user).deliver
     render 'devise/sessions/new' ,:layout => false
     else
     render 'devise/registrations/new',:layout => false
     end
   # end
  end

    # def show
    #   #super
    #   @user = User.find(params[:id])
    #end

  # GET /resource/edit
 # def edit
  #   super
  #  @roles = Role.all
  # end


  # PUT /resource
  #   # def update
    ##   super    #
    #  respond_to do |format|

    #    if @user.update(user_params)
    #      format.html { redirect_to userinfo_path, notice: 'Product was successfully updated.' }
    #      format.json {  render :json => [@user.add_jpg_url].to_json
    #      }
    #    else
    #      format.html { render :edit }
    #      format.json { render json: @user.errors, status: :unprocessable_entity }
    #    end

    #  end


    # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
 #end

 # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.for(:sign_up) << :attribute
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.for(:account_update) << :attribute
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end


  def set_confirmation_token
    confirmation_token = generate_authentication_token
  end

  private
   def user_params
     params.require(:user).permit(:mobile,:email,:password,:password_confirmation)
   end

  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).first
    end
  end
end
