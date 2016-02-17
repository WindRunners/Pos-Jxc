class JxcStoragesController < ApplicationController
  before_action :set_jxc_storage, only: [:show, :edit, :update, :destroy]
  before_action :set_userinfo, only:[:create,:update]

  def index
    @jxc_storages = JxcStorage.includes(:admin).order_by(:created_at => :desc).page(params[:page]).per(10)
  end

  def show
    @operation = 'show'
  end

  def new
    @jxc_storage = JxcStorage.new
  end

  def edit
  end

  def create
    @jxc_storage = JxcStorage.new(jxc_storage_params)
    @jxc_storage.userinfo = @userinfo
    respond_to do |format|
      if @jxc_storage.save
        # format.html { redirect_to jxc_storages_path, notice: '仓库信息成功创建.' }
        # format.js { render_js jxc_storages_path, notice: '仓库信息成功创建.' }
        # format.json { render :show, status: :created, location: @jxc_storage }
        format.json { render json: get_render_common_json(@jxc_storage,jxc_storages_path)}
      else
        # format.html { render :new }
        # format.js { render_js new_jxc_storage_path}
        # format.json { render json: @jxc_storage.errors, status: :unprocessable_entity }
        format.json { render json: get_render_common_json(@jxc_storage)}
      end
    end
  end

  def update
    @jxc_storage.userinfo = @userinfo
    respond_to do |format|
      if @jxc_storage.update(jxc_storage_params)
        # format.html { redirect_to jxc_storages_path, notice: '仓库信息成功更新.' }
        # format.js { render_js jxc_storages_path, notice: '仓库信息成功更新.' }
        # format.json { render :show, status: :ok, location: @jxc_storage }
        format.json { render json: get_render_common_json(@jxc_storage,jxc_storages_path)}
      else
        # format.html { render :edit }
        # format.js { render_js edit_jxc_storage_path(@jxc_storage) }
        # format.json { render json: @jxc_storage.errors, status: :unprocessable_entity }
        format.json { render json: get_render_common_json(@jxc_storage)}
      end
    end
  end

  def destroy
    @jxc_storage.destroy
    respond_to do |format|
      # format.html { redirect_to jxc_storages_url, notice: '仓库信息成功删除.' }
      format.js { render_js jxc_storages_url, notice: '仓库信息成功删除.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_jxc_storage
    @jxc_storage = JxcStorage.find(params[:id])
  end

  #创建的仓库默认所属运营商为当前用户所属运营商
  def set_userinfo
    @userinfo = current_user.userinfo if current_user.userinfo.present?
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def jxc_storage_params
    params.require(:jxc_storage).permit(:storage_name, :spell_code, :storage_type, :storage_code, :store_id, :admin_id, :address, :telephone, :status, :memo, :inventory_warning, :data_1, :data_2, :data_3, :data_4)
  end
end
