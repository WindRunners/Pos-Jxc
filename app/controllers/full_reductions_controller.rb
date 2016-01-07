class FullReductionsController < ApplicationController
  before_action :set_full_reduction, only: [:show, :edit, :update, :destroy]

  # GET /full_reductions
  # GET /full_reductions.json
  def index
    @preferential_way = params[:preferential_way] || "1" #默认是查询满减现金
    respond_to do |format|
      format.html
      format.json { render json: FullReductionsDatatable.new(view_context, current_user) }
    end
  end

  # GET /full_reductions/1
  # GET /full_reductions/1.json
  def show
    @giftSelectProductHash = @full_reduction.giftSelectProductHash 
    @selectCouponHash = @full_reduction.selectCouponHash
  end

  # GET /full_reductions/new
  def new
    @preferential_way = params[:preferential_way] || "1"
    @full_reduction = FullReduction.new(:preferential_way => @preferential_way, :use_goods => "1")
    @promotionImages = Warehouse::Promotion.where(:type => FullReduction.getTypeWarehouse(@preferential_way))
    initSession
  end

  # GET /full_reductions/1/edit
  def edit
    @promotionImages = Warehouse::Promotion.where(:type => FullReduction.getTypeWarehouse(@full_reduction.preferential_way))
    initSession
  end

  # POST /full_reductions
  # POST /full_reductions.json
  def create
    @full_reduction = FullReduction.new(full_reduction_params)
    
    @full_reduction.createUserInfo = current_user.userinfo if current_user.userinfo.present?
    case @full_reduction.preferential_way
      when "3" then @full_reduction.coupon_infos = session[:coupon_infos]
      when "4", "5" then @full_reduction.gifts_product_ids = session[:gifts_product_ids]
    end
    @full_reduction.participate_product_ids = session[:participate_product_ids]
    respond_to do |format|
      if @full_reduction.save
        initSession
        format.html { redirect_to :action => "index", :preferential_way => @full_reduction.preferential_way }
        format.json { render :show, status: :created, location: @full_reduction }
        format.js { render_js full_reductions_path(:preferential_way => @full_reduction.preferential_way) }
      else
        format.html { render :new }
        format.json { render json: @full_reduction.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /full_reductions/1
  # PATCH/PUT /full_reductions/1.json
  def update
    @full_reduction.old_full_reduction = @full_reduction.clone
    case @full_reduction.preferential_way
      when "3" then @full_reduction.coupon_infos = session[:coupon_infos]
      when "4", "5" then @full_reduction.gifts_product_ids = session[:gifts_product_ids]
    end
    @full_reduction.participate_product_ids = session[:participate_product_ids]
    respond_to do |format|
      if @full_reduction.update(full_reduction_params)
        initSession
        format.html { redirect_to :action => "index", :preferential_way => @full_reduction.preferential_way }
        format.json { render :show, status: :ok, location: @full_reduction }
        format.js { render_js full_reductions_path(:preferential_way => @full_reduction.preferential_way) }
      else
        format.html { render :edit }
        format.json { render json: @full_reduction.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /full_reductions/1
  # DELETE /full_reductions/1.json
  def destroy
    @full_reduction.destroy
    respond_to do |format|
      format.html { redirect_to "#{full_reductions_url}?preferential_way=#{@full_reduction.preferential_way}" }
      format.json { head :no_content }
      format.js { render_js full_reductions_path(:preferential_way => @full_reduction.preferential_way) }
    end
  end

  def products
    product_id = params[:product_id]
    if "d" == params[:operat]
      session[:participate_product_ids].delete(product_id)
    else
      session[:participate_product_ids] << product_id
    end
    respond_to do |format|
      format.json {render :json => {:success => true}.to_json}
    end
  end

  def coupons
    coupon_info = params[:coupon_info]
    coupon_quantity = coupon_info.split(",")
    if "d" == params[:operat]
      coupon_index = session[:coupon_infos].index {|cinfo| cinfo["coupon_id"] == coupon_quantity[0]}
      session[:coupon_infos].delete_at(coupon_index) if coupon_index.present?
    else
      session[:coupon_infos] << {"coupon_id"=> coupon_quantity[0], "quantity"=> coupon_quantity[1]}
    end

    respond_to do |format|
      format.json {render :json => {:success => true}.to_json}
    end
  end

  def giftProducts
    product_info = params[:product_info]
    product_quantity = product_info.split(",")
    if "d" == params[:operat]
      product_index = session[:gifts_product_ids].index {|pinfo| pinfo["product_id"] == product_quantity[0]}
      session[:gifts_product_ids].delete_at(product_index) if product_index.present?
    else
      session[:gifts_product_ids] << {"product_id"=> product_quantity[0], "quantity"=> product_quantity[1]}
    end

    respond_to do |format|
      format.json {render :json => {:success => true}.to_json}
    end
  end

  def loadProducts
    @products = Product.all.page params[:page]
    
    respond_to do |format|
      format.js
    end
  end
  
  private

    def initSession
      session[:participate_product_ids] = @full_reduction.participate_product_ids
      session[:coupon_infos] = @full_reduction.coupon_infos if "3" == @full_reduction.preferential_way
      session[:gifts_product_ids] = @full_reduction.gifts_product_ids if "4" == @full_reduction.preferential_way || "5" == @full_reduction.preferential_way
    end
    
    # Use callbacks to share common setup or constraints between actions.
    def set_full_reduction
      @full_reduction = FullReduction.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def full_reduction_params
      params.require(:full_reduction).permit(:name, :start_time, :end_time, :preferential_way, :quota, :reduction, :integral, :tag,
        :purchase_quantity, :gifts_quantity, :use_goods, :avatar)
    end
end
