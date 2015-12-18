class CouponsController < ApplicationController
  before_action :set_coupon, only: [:show, :edit, :update, :destroy]
  before_action :auth?
  before_action :get_products, only: [:new, :edit]
  before_action :buildHash
  # GET /coupons
  # GET /coupons.json
  def index
    if params[:customer_id].present?
      @coupons = Coupon.where(:customer_id => params[:customer_id])
    else
      respond_to do |format|
        format.html
        format.json { render json: CouponsDatatable.new(view_context, current_user) }
      end
    end
  end

  def products
    if "d" == params[:operat]
      session[:select_product_ids].delete(params[:product_id])
    else
      session[:select_product_ids] += params[:product_id].split(",")
    end
    Rails.logger.info "action[products]//session[:select_product_ids]==#{session[:select_product_ids]}"
    @products = session[:select_product_ids].collect {|pid| Product.shop(current_user).find(pid)}
    render :layout => false
  end

  def selectProducts
    Rails.logger.info "action[selectProducts]//session[:select_product_ids]==#{session[:select_product_ids]}"
    @products = Product.shop(current_user).where(:state_id => State.find_by(:value => "online").id, :coupon_id => nil, :id => {"$not" => {"$in" => session[:select_product_ids]}})
    render :layout => false
  end

  # GET /coupons/1
  # GET /coupons/1.json
  def show
  end

  # GET /coupons/new
  def new
    session[:select_product_ids] = Array.new
    @selectProductHashStr = "{}"
    @coupon = Coupon.new(:use_goods => "1", :order_amount_way => "1")
    @selectProductHashStr = @selectProductHash.to_s.gsub(/=>/, ":")
  end

  # GET /coupons/1/edit
  def edit
    session[:select_product_ids] = @coupon.product_ids
    @selectProductHash = Hash.new
    @coupon.product_ids.each do |pid|
      @selectProductHash[pid] = ""
    end
    @selectProductHashStr = @selectProductHash.to_s.gsub(/=>/, ":")
  end

  # POST /coupons
  # POST /coupons.json
  def create
    @coupon = Coupon.new(coupon_params)
    session[:select_product_ids].each do |product_id|
      @product = Product.shop(current_user).find(product_id)
      @coupon.product_ids << product_id
      @product.coupon_id = @coupon.id
      (@product.tags.present? ? @product.tags_array << @coupon.tag : @product.tags = @coupon.tag) if @coupon.tag.present?
      begin
        @product.shop(current_user).save
      rescue
      end
    end
    @coupon.userinfo = current_user.userinfo
    respond_to do |format|
      if @coupon.save
        format.html { redirect_to :action => "index" }
        format.json { render :show, status: :created, location: @coupon }
      else
        format.html { render :new }
        format.json { render json: @coupon.errors, status: :unprocessable_entity }
      end
    end
    session[:select_product_ids] = Array.new
  end

  # PATCH/PUT /coupons/1
  # PATCH/PUT /coupons/1.json
  def update
    @update_coupon = Coupon.new(coupon_params)
    if @app_key.present?
      if !@coupon.customer_ids.include?(params[:customer_id])
        @coupon.customer_ids << params[:customer_id]
      end
    else
      session[:select_product_ids] = [] if "0" == @update_coupon.use_goods
      @coupon.products.each do |p|
        if !session[:select_product_ids].include?(p.id.to_s)
          p.coupon_id = nil
          p.tags_array.delete(@coupon.tag)
          p.shop(current_user).save
          @coupon.product_ids.delete(p.id.to_s)
        else
          session[:select_product_ids].delete(p.id.to_s)
        end
      end
      session[:select_product_ids].each do |product_id|
        @product = Product.shop(current_user).find(product_id)
        @coupon.product_ids << product_id
        @product.coupon_id = @coupon.id
        if @coupon.tag.present?
            @product.tags_array.delete(@coupon.tag)
            @product.tags_array << @update_coupon.tag if @update_coupon.tag.present?
        else
            (@product.tags.present? ? @product.tags_array << @update_coupon.tag : @product.tags = @update_coupon.tag) if @update_coupon.tag.present?
        end
        begin
            @product.shop(current_user).save
        rescue
        end
      end
    end
    respond_to do |format|
      if @coupon.update(coupon_params)
        format.html { redirect_to :action => "index"}
        format.json { render :show, status: :ok, location: @coupon }
      else
        format.html { render :edit }
        format.json { render json: @coupon.errors, status: :unprocessable_entity }
      end
    end
    session[:select_product_ids] = Array.new
  end

  def invalided
    @coupon = Coupon.find(params[:coupon_id])
    if "invalided" != @coupon.aasm_state
      @coupon.to_invalid
      @coupon.save
    end
    respond_to do |format|
      format.html { redirect_to :action => "index"}
      if "invalided" == @coupon.aasm_state
        format.json {render :json => {:success => true}.to_json}
      else
        format.json {render :json => {:success => false}.to_json}
      end
    end
  end

  # DELETE /coupons/1
  # DELETE /coupons/1.json
  def destroy
    @coupon.products.each do |p|
      p.coupon_id = nil
      p.tags_array.delete(@coupon.tag)
      p.shop(current_user).save
    end
    @coupon.destroy
    respond_to do |format|
      format.html { redirect_to coupons_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_coupon
      @coupon = Coupon.find(params[:id])
    end

    def buildHash
      @aasmState = Hash.new
      @aasmState[:noBeging] = "未开始"
      @aasmState[:beging] = "正在进行"
      @aasmState[:end] = "已结束"
      @aasmState[:invalided] = "已失效"
    end
    
    def get_products
      @state = State.find_by(:value => "online")
      @products = Product.shop(current_user).where(:state_id => @state.id, :coupon_id => nil)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def coupon_params
      params.require(:coupon).permit(:title, :quantity, :value, :limit, :start_time, :end_time, :order_amount, :use_goods, :instructions,
          :buy_limit, :customer_id, :order_amount_way, :tag, :receive_count)
    end
    
    def auth?
      @app_key = request.headers['appkey']
      authenticate_user! if @app_key.blank? && "PEACOCK" == @app_key
    end
end
