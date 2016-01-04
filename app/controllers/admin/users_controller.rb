class Admin::UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  before_action :auth?

  def index
    @current_user = current_user
    @users = User.all.page params[:page]
  end

  def new
    @user = User.new
    @roles = Role.all

    # session[:user_params] ||= {}
    # @user = User.new(session[:user_params])
    # @user.current_step = session[:user_step]
  end

  def show
    if @app_key.present?
      @user=User.find(params[:id])
    else
      @user = User.find(params[:id])
    end
  end

  def edit
    @roles = Role.all
  end


  def create
    if params[:password].present?
      params[:user][:password] ||= params[:password]
    end
    @user = User.new(user_params)
    if @app_key.present?
      @user.userinfo=Userinfo.create(pdistance: 1)
    end
    respond_to do |format|
      if @user.save
        if @app_key.present?
          # format.html { redirect_to [:admin, @user], notice: 'User was successfully updated.' }
          format.json { render :show, status: :ok }
        else
          format.html { redirect_to [:admin, @user], notice: 'User was successfully updated.' }
          format.json { render :show, status: :ok }
        end
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end


  def password
    p params
  end

  def upload
    @user=User.find(current_user.id)
    # @user.avatar.destroy
    @user.avatar= params[:user][:avatar]
    @user.save
    respond_to do |format|
      format.html{redirect_to "/#/userinfos/#{current_user.userinfo_id}"}
      format.js{render_js "/#/userinfos/#{current_user.userinfo_id}"}
    end

  end


  def update

    respond_to do |format|

      puts params[:code]

      result = false

      if params[:user][:password].blank? && params[:user][:password_confirmation].blank?

        result = @user.update_without_password(user_params)
      else
        result = @user.update(user_params)
      end
      if result

        Role.all.each do |role|
          @user.revoke role.name
        end

        unless params[:user][:roles].blank?
          params[:user][:roles].each do |role|
            @user.add_role role
          end
        end
        format.html { redirect_to [:admin, @user], notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok }
        format.js{ render_js admin_user_path(@user) }

      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
        format.js{ render_js edit_admin_user_path(@user) }
      end
    end
  end

  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to admin_users_path, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:mobile, :password, :password_confirmation,:userinfo_id ,:name, :admin, :role, :email, :step, :audit_desc,:name_condition)
  end

  def auth?
    @app_key = request.headers['appkey']
  end

end
