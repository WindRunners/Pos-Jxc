class DeliveryUsersController < ApplicationController
  before_action :set_delivery_user, only: [:show, :edit, :update, :destroy, :check, :check_save, :store_index, :store_save]
  skip_before_action :authenticate_user!, only: [:datatable]
  # GET /delivery_users
  # GET /delivery_users.json
  def index

    #@delivery_users = DeliveryUser.all.page(params[:page]).per(2)
    reqParams = {mobile: params[:mobile], status: params[:status]}
    @delivery_user = DeliveryUser.new(mobile: params[:mobile], status: params[:status])
    @delivery_users = policy_scope(@delivery_user).page(params[:page])
  end

  # GET /delivery_users/1
  # GET /delivery_users/1.json
  def show
    @userinfo = Userinfo.where(_id: @delivery_user['userinfo_id']).first if current_user.has_role? :SuperAdmin
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
        format.js { render_js delivery_user_path(@delivery_user) }
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
        format.js { render_js delivery_user_path(@delivery_user) }
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


    userinfo_name = params[:userinfo_name]
    userinfo_shopname = params[:userinfo_shopname]

    whereParams = {}
    whereParams['name'] = /#{userinfo_name}/ if userinfo_name.present?
    whereParams['shopname'] = /#{userinfo_shopname}/ if userinfo_shopname.present?

    @userinfo = Userinfo.where(_id: @delivery_user['userinfo_id']).first if current_user.has_role? :SuperAdmin
    @userinfos = Userinfo.where(whereParams).page(params[:page]) if current_user.has_role? :SuperAdmin

  end

  # PATCH/PUT /delivery_users/1
  # PATCH/PUT /delivery_users/1.json
  def check_save
    respond_to do |format|

      puts "保存参数为:#{params.require(:delivery_user).permit(:status, :userinfo_id)}"

      if @delivery_user.update(params.require(:delivery_user).permit(:status, :userinfo_id))
        @notice = '审核成功!'
        format.js { render_js delivery_user_path(@delivery_user) }
        format.json { render :show, status: :ok, location: @delivery_user }
      else
        format.js { render_js delivery_user_path(@delivery_user) }
        format.json { render json: @delivery_user.errors, status: :unprocessable_entity }
      end
    end
  end


  # DELETE /delivery_users/1
  # DELETE /delivery_users/1.json
  def destroy
    @delivery_user.destroy
    respond_to do |format|
      format.js { render_js delivery_users_url }
      # format.html { redirect_to delivery_users_url, notice: 'Delivery user was successfully destroyed.' }
      format.json { head :no_content }
    end
  end


  #门店管理
  def store_index

    @store_ids = @delivery_user['store_ids']
    @store_ids = [] if !@store_ids.present?
    @stores = Store.where({"userinfo_id" => @delivery_user['userinfo_id']})
  end

  #门店保存
  def store_save

    begin

      op = params[:op] #add 添加，remove 移除
      store_id = params[:store_id]
      object_store_id = BSON::ObjectId(store_id)

      if (op == "add")

        @delivery_user.add_to_set({"store_ids" => object_store_id})
      else
        @delivery_user.pull({"store_ids" => object_store_id})
      end
      respond_to do |format|
        format.json { render json: {"flag" => 1, "msg" => "门店操作成功！"} }
      end
    rescue Exception => e #异常捕获
      puts e
      respond_to do |format|
        format.json { render json: {"flag" => 0, "msg" => "门店操作失败，服务器出现异常！"} }
      end
    end
  end


  #配送员datatable
  def datatable
    length = params[:length].to_i #页显示记录数
    start = params[:start].to_i #记录跳过的行数


    searchValue = params[:search][:value] #查询
    searchParams = {}
    searchParams['mobile'] = /#{searchValue}/
    searchParams['authentication_token'] = {"$exists" => true}
    orinfo = []
    if current_user.store_ids.present?
      current_user['store_ids'].each do |store_id|
        orinfo << {'store_ids' => store_id}
      end
    else
      orinfo << {'store_ids' => ""}
    end

    searchParams['$or'] = orinfo

    tabledata = {}
    totalRows = DeliveryUser.where(searchParams).count
    tabledata['data'] = DeliveryUser.where(searchParams).page((start/length)+1).per(length)
    tabledata['draw'] = params[:draw] #访问的次数
    tabledata['recordsTotal'] = totalRows
    tabledata['recordsFiltered'] = totalRows

    respond_to do |format|
      format.json { render json: tabledata }
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
