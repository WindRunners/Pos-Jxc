class PromotionDiscountsController < ApplicationController
  before_action :set_promotion_discount, only: [:show, :edit, :update, :destroy]
  before_action :get_products, only: [:new, :edit]
  before_action :buildHash
  
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
    @selectProductHash = @promotion_discount.selectProductHash
  end

  # GET /promotion_discounts/new
  def new
    @selectProductHash = Hash.new
    @selectProductHashStr = "{}"
    type = params[:type] || "0"
    @promotion_discount = PromotionDiscount.new(:type => type)
    @promotions = Warehouse::Promotion.where(:type => PromotionDiscount.getTypeWarehouse(type))
  end

  # GET /promotion_discounts/1/edit
  def edit
    @selectProductHash = @promotion_discount.selectProductHash
    @selectProductHashStr = @selectProductHash.to_s.gsub(/=>/, ":")
    @promotions = Warehouse::Promotion.where(:type => PromotionDiscount.getTypeWarehouse(@promotion_discount.type))
  end

  # POST /promotion_discounts
  # POST /promotion_discounts.json
  def create
    @promotion_discount = PromotionDiscount.new(promotion_discount_params)
    @selectProductHash = eval(params[:selectProductHash])
    @selectProductHash.each do |product_id, value|
      product = Product.shop(current_user).find(product_id.to_s)
      if "0" == @promotion_discount.type
        @promotion_discount.participate_product_ids << product_id.to_s
      else
        @promotion_discount.participate_product_ids << {:product_id => product_id.to_s, :product_name => product.title, :price => value}
      end
      product.promotion_discount_id = @promotion_discount.id.to_s
      (product.tags.present? ? product.tags_array << @promotion_discount.tag : product.tags = @promotion_discount.tag) if @promotion_discount.tag.present?
      begin
        product.shop(current_user).save
      rescue
      end
    end
    @promotion_discount.createUserInfo = current_user.userinfo if current_user.userinfo.present?
    respond_to do |format|
      if @promotion_discount.save
        format.html { redirect_to :action => "index", :type => @promotion_discount.type }
        format.json { render :show, status: :created, location: @promotion_discount }
        format.js { render_js promotion_discounts_path(:type => @promotion_discount.type) }
      else
        format.html { render :new }
        format.json { render json: @promotion_discount.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /promotion_discounts/1
  # PATCH/PUT /promotion_discounts/1.json
  def update
    @update_promotion_discount = PromotionDiscount.new(promotion_discount_params)
    @selectProductHash = eval(params[:selectProductHash])
    @promotion_discount.participate_product_ids.clear
    @selectProductHash.each do |product_id, value|
      product = Product.shop(current_user).find(product_id.to_s)
      if "0" == @promotion_discount.type
        @promotion_discount.participate_product_ids << product_id.to_s
      else
        @promotion_discount.participate_product_ids << {:product_id => product_id.to_s, :product_name => product.title, :price => value}
      end
      product.promotion_discount_id = @promotion_discount.id.to_s
      if @promotion_discount.tag.present?
        product.tags_array.delete(@promotion_discount.tag)
        product.tags_array << @update_promotion_discount.tag if @update_promotion_discount.tag.present?
      else
        (product.tags.present? ? product.tags_array << @update_promotion_discount.tag : product.tags = @update_promotion_discount.tag) if @update_promotion_discount.tag.present?
      end
      begin
        product.shop(current_user).save
      rescue
      end
    end
    respond_to do |format|
      if @promotion_discount.update(promotion_discount_params)
        format.html { redirect_to :action => "index", :type => @promotion_discount.type }
        format.json { render :show, status: :ok, location: @promotion_discount }
        format.js { render_js promotion_discounts_path(:type => @promotion_discount.type) }
      else
        format.html { render :edit }
        format.json { render json: @promotion_discount.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /promotion_discounts/1
  # DELETE /promotion_discounts/1.json
  def destroy
    @promotion_discount.participateProducts.each do |p|
      p.promotion_discount_id = nil
      p.tags_array.delete(@promotion_discount.tag)
      p.panic_price = 0
      begin
        p.shop(current_user).save
      rescue
      end
    end
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

    def buildHash
      @aasmState = Hash.new
      @aasmState[:noBeging] = "未开始"
      @aasmState[:beging] = "正在进行"
      @aasmState[:end] = "已结束"
    end
    
    def get_products
      @state = State.find_by(:value => "online")
      @products = Product.shop(current_user).where({:state_id => @state.id, "$or" => [:promotion_discount_id => nil, :panic_price => 0]})
    end
    
    # Never trust parameters from the scary internet, only allow the white list through.
    def promotion_discount_params
      params.require(:promotion_discount).permit(:title, :discount, :type, :participate_product_ids, :aasm_state, :tag, :start_time, :end_time, :use_goods, :avatar)
    end
end
