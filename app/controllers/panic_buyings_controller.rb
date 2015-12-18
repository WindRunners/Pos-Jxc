class PanicBuyingsController < ApplicationController
  before_action :set_panic_buying, only: [:show, :edit, :update, :destroy]
  # before_action :authenticate_user!, except: [:panic_buying_list]

  helpers do
    def current_user
      token = headers['Authentication-Token']
      @current_user = User.find_by(authentication_token: token)
    rescue
      error!('401 Unauthorized', 401)

    end

    def authenticate!
      error!('401 Unauthorized', 401) unless current_user
    end
  end
  # GET /panic_buyings
  # GET /panic_buyings.json
  def index
    @state = ""
  end


  def panic_table

    parm = Hash.new
    parm[:userinfo] = current_user.userinfo
    parm[:state] = {"$in" => [0,1,2]}

    @state = ""
    if !params[:state].empty?
      parm[:state] = params[:state].to_i
      @state = params[:state].to_i
    end

    @panic_buyings = PanicBuying.where(parm).order(beginTime: :asc)

    respond_to do |format|
      format.html { render :partial => "panic_table", :layout => false }
    end
  end

  # GET /panic_buyings/new
  def new
    @panic_buying = PanicBuying.new
  end

  # POST /panic_buyings
  # POST /panic_buyings.json
  def create

  end


  # GET /panic_buyings/1
  # GET /panic_buyings/1.json
  def show
    @panic_buying = PanicBuying.find(params[:id])
    @products = @panic_buying.products
  end


  #获取没有参加活动的商品列表
  def product_list
    @panic_buying_id = params[:id]
    @current_userinfo = current_user.userinfo
    @products = Product.shop_id(@current_userinfo.id).where(:panic_buying => nil,:panic_price => 0).order(created_at: :desc).page(params[:page])
    respond_to do |format|
      format.html { render :partial => 'product_list', :layout => false }
    end
  end

  #获取没有参加活动的商品列表
  def product
    @panic_buying_id = params[:panic_buying_id]
    @current_userinfo = current_user.userinfo

    @product = Product.shop_id(@current_userinfo.id).find(params[:id])

    respond_to do |format|
      format.html { render :partial => 'product', :layout => false }
    end
  end

  #为活动添加商品信息
  def add_product

    @panic_buying = PanicBuying.find(params[:panic_buying_id])

    product = Product.shop_id(@panic_buying.userinfo.id).find(params[:product_id])

    product.panic_buying = @panic_buying
    product.panic_quantity = params[:panic_quantity]
    product.panic_price = params[:panic_price]

    respond_to do |format|
      if product.shop_id(@panic_buying.userinfo.id).save!
        format.js { render_js panic_buying_path(@panic_buying.id) }
      else
        format.html { render :new }
      end
    end
  end

  #为活动添加商品信息
  def remove_product
    @panic_buying = PanicBuying.find(params[:panic_buying_id])
    product = Product.shop_id(@panic_buying.userinfo.id).find(params[:product_id])

    product.shop_id(@panic_buying.userinfo.id).update_attributes!(:panic_buying => nil,:panic_quantity => 0,:panic_price => 0)

    redirect_to panic_buying_path(@panic_buying.id)

  end


  # GET /panic_buyings/1/edit
  def edit

  end



  # PATCH/PUT /panic_buyings/1
  # PATCH/PUT /panic_buyings/1.json
  def update
    respond_to do |format|
      if @panic_buying.update!(panic_buying_params)

        format.html { redirect_to panic_buyings_path, notice: 'Panic buying was successfully updated.' }
        format.json { render :show, status: :ok, location: @panic_buying }
      else
        format.html { render :edit }
        format.json { render json: @panic_buying.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /panic_buyings/1
  # DELETE /panic_buyings/1.json
  def destroy
    @panic_buying.destroy
    respond_to do |format|
      format.html { redirect_to panic_buyings_url, notice: 'Panic buying was successfully destroyed.' }
      format.json { head :no_content }
    end
  end




  private
    # Use callbacks to share common setup or constraints between actions.
    def set_panic_buying
      @panic_buying = PanicBuying.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def panic_buying_params
      params.require(:panic_buying).permit(:panic_name,:panic_price, :cycle, :panic_quantity, :beginTime, :endTime,:product_id,:panic_type)
    end
end
