class PromotionDiscountsController < ApplicationController
  before_action :set_promotion_discount, only: [:show, :edit, :update, :destroy]
  
  # GET /promotion_discounts
  # GET /promotion_discounts.json
  def index
    @type = params[:type] || "0"
    respond_to do |format|
      format.html
      format.json { render json: PromotionDiscountsDatatable.new(view_context, current_user) }
    end
  end

  # GET /promotion_discounts/1
  # GET /promotion_discounts/1.json
  def show
  end

  def products
    type = params[:type]
    operat = params[:operat]
    product_id = params[:product_id]
    product_price = params[:product_id].split(",")
    if "d" == operat
      if "0" == type
        session[:promotion_select_product_ids].delete(product_id)
      else
        productIndex = session[:promotion_select_product_ids].index {|pinfo| pinfo["product_id"] == product_price[0]}
        session[:promotion_select_product_ids].delete_at(productIndex) if productIndex.present?
      end
    else
      if "0" == type
        session[:promotion_select_product_ids] << product_id if !session[:promotion_select_product_ids].include?(product_id)
      else
        session[:promotion_select_product_ids] << {"product_id" => product_price[0], "price" => product_price[1].to_f}
      end
    end
    respond_to do |format|
      format.json {render :json => {:success => true}.to_json}
    end
  end

  # GET /promotion_discounts/new
  def new
    session[:promotion_select_product_ids] = []
    type = params[:type] || "0"
    @promotion_discount = PromotionDiscount.new(:type => type)
    @promotions = Warehouse::Promotion.where(:type => PromotionDiscount.getTypeWarehouse(type))
  end

  # GET /promotion_discounts/1/edit
  def edit
    session[:promotion_select_product_ids] = @promotion_discount.participate_product_ids
    @promotions = Warehouse::Promotion.where(:type => PromotionDiscount.getTypeWarehouse(@promotion_discount.type))
  end

  # POST /promotion_discounts
  # POST /promotion_discounts.json
  def create
    @promotion_discount = PromotionDiscount.new(promotion_discount_params)
    @promotion_discount.createUserInfo = current_user.userinfo if current_user.userinfo.present?
    @promotion_discount.participate_product_ids = session[:promotion_select_product_ids]
    respond_to do |format|
      if @promotion_discount.save
        session[:promotion_select_product_ids] = []
        format.html { redirect_to :action => "index", :type => @promotion_discount.type }
        format.json { render :show, status: :created, location: @promotion_discount }
        format.js { render_js promotion_discounts_path(:type => @promotion_discount.type) }
      else
        format.html { render :new }
        format.json { render json: @promotion_discount.errors, status: :unprocessable_entity }
      end
    end
    # session[:promotion_select_product_ids] = Array.new

  end

  # PATCH/PUT /promotion_discounts/1
  # PATCH/PUT /promotion_discounts/1.json
  def update
    @update_promotion_discount = PromotionDiscount.new(promotion_discount_params)
    @promotion_discount.old_promotion_discount = @promotion_discount.clone
    @promotion_discount.participate_product_ids = session[:promotion_select_product_ids]
    respond_to do |format|
      if @promotion_discount.update(promotion_discount_params)
        session[:promotion_select_product_ids] = []
        format.html { redirect_to :action => "index", :type => @promotion_discount.type }
        format.json { render :show, status: :ok, location: @promotion_discount }
        format.js { render_js promotion_discounts_path(:type => @promotion_discount.type) }
      else
        format.html { render :edit }
        format.json { render json: @promotion_discount.errors, status: :unprocessable_entity }
      end
    end
    session[:promotion_select_product_ids] = Array.new
  end

  # DELETE /promotion_discounts/1
  # DELETE /promotion_discounts/1.json
  def destroy
    @promotion_discount.destroy
    respond_to do |format|
      format.html { redirect_to :action => "index", :type => @promotion_discount.type }
      format.json { head :no_content }
      format.js { render_js promotion_discounts_path(:type => @promotion_discount.type) }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_promotion_discount
      @promotion_discount = PromotionDiscount.find(params[:id])
    end
    
    # Never trust parameters from the scary internet, only allow the white list through.
    def promotion_discount_params
      params.require(:promotion_discount).permit(:title, :discount, :type, :participate_product_ids, :aasm_state, :tag, :start_time, :end_time, :use_goods, :avatar)
    end
end
