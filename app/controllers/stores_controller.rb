class StoresController < ApplicationController
  before_action :set_store, only: [:show, :edit, :update, :destroy]

  # GET /stores
  # GET /stores.json
  def index
    @stores = Store.where(userinfo_id: current_user.userinfo.id).page(params[:page]).order('created_at DESC')
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
        format.html { redirect_to @store, notice: 'Store was successfully created.' }
        format.json { render :show, status: :created, location: @store }
      else
        format.html { render :new }
        format.json { render json: @store.errors, status: :unprocessable_entity }
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
        format.html { redirect_to @store, notice: 'Store was successfully updated.' }
        format.json { render :show, status: :ok, location: @store }
      else
        format.html { render :edit }
        format.json { render json: @store.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stores/1
  # DELETE /stores/1.json
  def destroy
    @store.destroy
    respond_to do |format|
      format.html { redirect_to stores_url, notice: 'Store was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def delivery_users
    # 门店自主选择配送员
    @delivery_users = DeliveryUser.all.page(params[:page]).order('created_at DESC')
  end

  def add_delivery_user
    # 配送员增加
    @delivery_users = DeliveryUser.all
    @du = DeliveryUser.find(params[:id])
    @store = Store.find(params[:store_id])
    @store.delivery_users << @du
    @store.save
    redirect_to store_delivery_users_url
  end

  def reduce_delivery_user
    # 配送员移除
    @delivery_users = DeliveryUser.all
    @du = DeliveryUser.find(params[:id])
    @store = Store.find(params[:store_id])
    @store.delivery_users.delete(@du)
    @store.save
    redirect_to store_delivery_users_url
  end

  def search
    @stores = Store.search(params[:qrcode]).page(params[:page]).order('created_at DESC')
    render :index
  end


  private
  # Use callbacks to share common setup or constraints between actions.
  def set_store
    @store = Store.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def store_params
    params.require(:store).permit(:name, :manager, :describe, :longitude, :latitude, :position, :idpf, :idpb, :bp, :type, :qrcode)
  end
end
