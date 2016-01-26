class Admin::UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  before_action :auth?

  def index
    @current_user = current_user
    @users = User.all.page(params[:page])
    # @users = User.where({:userinfo_id => @current_user['userinfo_id']}).page(params[:page])
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
    # @roles = Role.all
    @roles = Role.where({})
    Rails.logger.info "修改"
    @roles = Role.where({})
    @roles = Role.where({})
  end


  #创建用户
  def create
    # if params[:password].present?
    #   params[:user][:password] ||= params[:password]
    # end
    @user = User.new(user_params)
    #初始化密码: 123456
    @user.password = "123456"
    @user['userinfo_id'] = current_user['userinfo_id']
    if @app_key.present?
      @user.userinfo=Userinfo.create(pdistance: 1)
    end
    respond_to do |format|
      begin

        if @user.save

          unless params[:user][:roles].blank?
            params[:user][:roles].each do |role|
              @user.add_role role
            end
          end
          # if @app_key.present?
            # format.html { redirect_to [:admin, @user], notice: 'User was successfully updated.' }
            # format.json { render :show, status: :ok }
          # else
            # format.js { render_js admin_users_path }
            # format.html { redirect_to [:admin, @user], notice: 'User was successfully updated.' }
            # format.json { render :show, status: :ok }

          # end
          format.json { render json: get_render_json(1,nil,admin_users_path) }
        else
          # format.html { render :new }
          # format.json { render json: @user.errors, status: :unprocessable_entity }
          format.json { render json: get_render_json(0,@user.errors.messages) }
        end
      rescue Exception => e
        p e.message
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
      format.html { redirect_to "/#/userinfos/#{current_user.userinfo_id}" }
      format.js { render_js "/#/userinfos/#{current_user.userinfo_id}" }
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
        format.js { render_js admin_user_path(@user) }

      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
        format.js { render_js edit_admin_user_path(@user) }
      end
    end
  end

  def destroy
    @user.destroy
    respond_to do |format|
      # format.html { redirect_to admin_users_path, notice: 'User was successfully destroyed.' }
      format.js { render_js admin_users_path, notice: 'Feedback was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  #用户负责门店
  def manage_store
    begin
      op = params[:op] #add 添加  ,remove 移除
      store_id = params[:store_id]
      object_store_id = BSON::ObjectId(store_id)
      @current_user = current_user
      # binding.pry
      if (op=="add")
        @current_user.add_to_set({"store_ids" => object_store_id})
      else
        @current_user.pull({"store_ids" => object_store_id})
      end
      respond_to do |format|
        format.json { render json: {"flag" => 1, "msg" => "门店操作成功！"} }
      end
    rescue Exception => e #异常捕获
      puts e.message
      respond_to do |format|
        format.json { render json: {"flag" => 0, "msg" => "门店操作失败，服务器出现异常！"} }
      end
    end
  end
  
  #管理员用户对普通用户进行密码重置:123456
  def reset_password
    set_user
    # binding.pry
    @user.password= '123456'
    respond_to do |format|
      begin
        if @user.save
          # format.js {render_js admin_users_path }
          format.json { render json: get_render_json(1,nil,admin_users_path) }
        else
          # format.html { render :new }
          # format.json { render json: @user.errors, status: :unprocessable_entity }
          # format.js {render_js admin_users_path }
          format.json { render json: get_render_json(0,@user.errors.messages) }
        end
      rescue Exception => e
        p e.message
      end
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:mobile, :password, :password_confirmation, :userinfo_id, :name, :admin, :role, :email, :step, :audit_desc, :name_condition)
  end

  def auth?
    @app_key = request.headers['appkey']
  end

end
