class DeliveryUsersController < ApplicationController
  before_action :set_delivery_user, only: [:show, :edit, :update, :destroy,:check,:check_save]

  # GET /delivery_users
  # GET /delivery_users.json
  def index

    #@delivery_users = DeliveryUser.all.page(params[:page]).per(2)
    reqParams = {mobile: params[:mobile],status: params[:status]}
    @delivery_user = DeliveryUser.new(mobile: params[:mobile],status: params[:status])
    @delivery_users = policy_scope(@delivery_user).page(params[:page])
  end

  # GET /delivery_users/1
  # GET /delivery_users/1.json
  def show
  end

  # GET /delivery_users/new
  def new
    @delivery_user = DeliveryUser.new
  end

  # GET /delivery_users/1/edit
  def edit
  end

  # POST /delivery_users
  # POST /delivery_users.json
  def create
    @delivery_user = DeliveryUser.new(delivery_user_params)

    respond_to do |format|
      if @delivery_user.save
        # format.html { redirect_to @delivery_user, notice: 'Delivery user was successfully created.' }
        format.js {render_js delivery_user_path(@delivery_user)}
        format.json { render :show, status: :created, location: @delivery_user }
      else
        format.html { render :new }
        format.json { render json: @delivery_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /delivery_users/1
  # PATCH/PUT /delivery_users/1.json
  def update
    respond_to do |format|
      if @delivery_user.update(delivery_user_params)
        format.js {render_js delivery_user_path(@delivery_user)}
        # format.html { redirect_to @delivery_user, notice: 'Delivery user was successfully updated.' }
        format.json { render :show, status: :ok, location: @delivery_user }
      else
        format.html { render :edit }
        format.json { render json: @delivery_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /delivery_users/1
  # GET /delivery_users/1.json
  def check

    @userinfo = Userinfo.where(_id: @delivery_user['userinfo_id']).first if current_user.has_role? :SuperAdmin
    @userinfos = Userinfo.all.page(params[:page]) if current_user.has_role? :SuperAdmin

  end

  # PATCH/PUT /delivery_users/1
  # PATCH/PUT /delivery_users/1.json
  def check_save
    respond_to do |format|

      puts "保存参数为:#{params.require(:delivery_user).permit(:status,:userinfo_id)}"

      if @delivery_user.update(params.require(:delivery_user).permit(:status,:userinfo_id))
        @notice = '审核成功!'
        format.js {render_js delivery_user_path(@delivery_user)}
        format.json { render :show, status: :ok, location: @delivery_user }
      else
        format.js {render_js delivery_user_path(@delivery_user)}
        format.json { render json: @delivery_user.errors, status: :unprocessable_entity }
      end
    end
  end


  # DELETE /delivery_users/1
  # DELETE /delivery_users/1.json
  def destroy
    @delivery_user.destroy
    respond_to do |format|
      format.js {render_js delivery_users_url}
      # format.html { redirect_to delivery_users_url, notice: 'Delivery user was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_delivery_user
      @delivery_user = DeliveryUser.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def delivery_user_params
      params.require(:delivery_user).permit(:real_name, :user_desc, :generate, :scaffold, :DeliveryUser, :real_name, :user_desc, :work_status, :mobile, :login_type, :status, :position)
    end
end
