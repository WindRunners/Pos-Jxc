class JxcStoragesController < ApplicationController
  before_action :set_jxc_storage, only: [:show, :edit, :update, :destroy]

  def index
    @jxc_storages = JxcStorage.order_by(:created_at => :desc).page(params[:page]).per(10)
  end

  def show
  end

  def new
    @jxc_storage = JxcStorage.new
  end

  def edit
  end

  def create
    @jxc_storage = JxcStorage.new(jxc_storage_params)

    respond_to do |format|
      if @jxc_storage.save
        format.html { redirect_to jxc_storages_path, notice: '仓库信息成功创建.' }
        format.json { render :show, status: :created, location: @jxc_storage }
      else
        format.html { render :new }
        format.json { render json: @jxc_storage.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @jxc_storage.update(jxc_storage_params)
        format.html { redirect_to jxc_storages_path, notice: '仓库信息成功更新.' }
        format.json { render :show, status: :ok, location: @jxc_storage }
      else
        format.html { render :edit }
        format.json { render json: @jxc_storage.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @jxc_storage.destroy
    respond_to do |format|
      format.html { redirect_to jxc_storages_url, notice: '仓库信息成功删除.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_jxc_storage
    @jxc_storage = JxcStorage.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def jxc_storage_params
    params.require(:jxc_storage).permit(:storage_name, :spell_code, :storage_type, :storage_code, :admin, :admin_phone, :address, :telephone, :status, :memo, :data_1, :data_2, :data_3, :data_4)
  end
end
