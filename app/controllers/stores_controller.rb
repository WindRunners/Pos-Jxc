class StoresController < ApplicationController
  before_action :set_store, only: [:show, :edit, :update, :destroy]

  # GET /stores
  # GET /stores.json
  def index
    if params[:u_id].present?
      @manage_store=params[:state]
      @user_id=params[:u_id]
      @user = User.find(params[:u_id])
      @current_user = current_user
      @store_ids = @user['store_ids']
      if @store_ids==nil
        @store_ids=[]
      end
      conditionParams = {}
      name_condition=params[:name] || ''
      conditionParams['userinfo_id'] = @user.userinfo.id
      conditionParams['name'] = /#{name_condition}/ if name_condition.present?
      @stores = Store.where(conditionParams).page(params[:page]).order('created_at DESC')
    else
      name_condition=params[:name] || ''
      conditionParams = {}
      conditionParams['name'] =  /#{name_condition}/ if name_condition.present?
      if current_user.userinfo.present?
        conditionParams['userinfo_id'] = current_user.userinfo.id
        @stores = Store.where(conditionParams).page(params[:page]).order('created_at DESC')
      else
        @stores = nil
      end
    end
  end

  # GET /stores/1
  # GET /stores/1.json
  def show
  end

  # GET /stores/new
  def new
    @store = Store.new
  end

  # GET /stores/1/edit
  def edit
  end

  # POST /stores
  # POST /stores.json
  def create
    @store = Store.new(store_params)
    @store.userinfo_id = current_user.userinfo.id
    respond_to do |format|
      if @store.save
        format.json { render json: get_render_common_json(@store,stores_path) }
      else
        format.json { render json: get_render_common_json(@store) }
      end
    end
  end

  def upload

  end

  # PATCH/PUT /stores/1
  # PATCH/PUT /stores/1.json
  def update
    respond_to do |format|
      if @store.update(store_params)
        format.json { render json: get_render_common_json(@store,stores_path) }
      else
        format.json { render json: get_render_common_json(@store) }
      end
    end
  end

  # DELETE /stores/1
  # DELETE /stores/1.json
  def destroy
    @store.destroy
    respond_to do |format|
      format.js { render_js stores_path }
      format.html { redirect_to stores_url, notice: 'Store was successfully destroyed.' }
      format.json { head :no_content }
    end
  end


  # 门店自主选择配送员

  def delivery_users
    mobile_condition=params[:mobile] || ''
    conditionParams = {}
    conditionParams['mobile'] = /#{mobile_condition}/ if mobile_condition.present?
    conditionParams['userinfo_id'] = current_user.userinfo.id if current_user.present?
    conditionParams['status'] = 1
    @store = Store.find(params[:store_id])
    @delivery_users = DeliveryUser.where(conditionParams).page(params[:page]).order('created_at DESC')
  end


  # 配送员增加
  def add_delivery_user
    delivery_user = DeliveryUser.find(params[:delivery_user_id])
    store = Store.find(params[:store_id])
    delivery_user.stores << store
    respond_to do |format|
      if store.save && delivery_user.save
        format.js { render_js store_delivery_users_path }
        format.json { head :no_content }
      else
        format.js { render_js store_delivery_users_path }
        format.json { head :no_content }
      end
    end
  end


  # 配送员移除
  def reduce_delivery_user
    delivery_user = DeliveryUser.find(params[:delivery_user_id])
    store = Store.find(params[:store_id])
    delivery_user.stores.delete(store)
    respond_to do |format|
      if store.save && delivery_user.save
        format.js { render_js store_delivery_users_path }
        format.json { head :no_content }
      else
        format.js { render_js store_delivery_users_path }
        format.json { head :no_content }
      end
    end
  end


  private
  # Use callbacks to share common setup or constraints between actions.
  def set_store
    @store = Store.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def store_params
    params.require(:store).permit(:name, :manager, :describe, :longitude, :latitude, :position, :idpf, :idpb, :bp, :type)
  end
end
