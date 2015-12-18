class FullReductionsController < ApplicationController
  before_action :set_full_reduction, only: [:show, :edit, :update, :destroy]
  before_action :get_products, only: [:new, :edit]
  before_action :get_coupons, only: [:new, :edit]
  before_action :buildHash

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
    @selectProductHashStr = "{}"
    @giftSelectProductHashStr = "{}"
    @selectCouponHashStr = "{}"
    @couponIds = []
    @participateProductId = []
    @giftsProductId = []
    @selectCouponHash = Hash.new
    @giftSelectProductHash = Hash.new
    @preferential_way = params[:preferential_way] || "1"
    @full_reduction = FullReduction.new(:preferential_way => @preferential_way, :use_goods => "1")
    @promotionImages = Warehouse::Promotion.where(:type => FullReduction.getTypeWarehouse(@preferential_way))
  end

  # GET /full_reductions/1/edit
  def edit
    #设置页面要用到的列表数据
    @couponIds = @full_reduction.couponIds
    @selectCouponHash = @full_reduction.selectCouponHash
    @selectProductHash = @full_reduction.selectProductHash
    @giftSelectProductHash = @full_reduction.giftSelectProductHash
    @giftsProductId = @full_reduction.giftsProductId
    @selectProductHashStr = @selectProductHash.to_s.gsub(/=>/, ":")
    @giftSelectProductHashStr = @giftSelectProductHash.to_s.gsub(/=>/, ":")
    @selectCouponHashStr = @selectCouponHash.to_s.gsub(/=>/, ":")
    @promotionImages = Warehouse::Promotion.where(:type => FullReduction.getTypeWarehouse(@full_reduction.preferential_way))
  end

  # POST /full_reductions
  # POST /full_reductions.json
  def create
    @full_reduction = FullReduction.new(full_reduction_params)
    @selectProductHash = eval(params[:selectProductHash] || "{}")
    @giftSelectProductHash = eval(params[:giftSelectProductHash] || "{}")
    @selectCouponHash = eval(params[:selectCouponHash] || "{}")
    #设置赠送的优惠券列表
    @selectCouponHash.each do |coupon_id, value|
      begin
        coupon = Coupon.find(coupon_id.to_s)
        @full_reduction.coupon_infos << {:coupon_id => coupon_id.to_s, :quantity => value}
        coupon.full_reduction_ids << @full_reduction.id.to_s
        coupon.save
      end
    end
    #设置参与的商品列表
    @selectProductHash.each do |product_id, value|
      product = Product.shop(current_user).find(product_id.to_s)
      @full_reduction.participate_product_ids << product_id.to_s
      product.full_reduction_id = @full_reduction.id.to_s
      (product.tags.present? ? product.tags_array << @full_reduction.tag : product.tags = @full_reduction.tag) if @full_reduction.tag.present?
      begin
        product.shop(current_user).save
      rescue
      end
    end
    #设置赠送的商品列表
    @giftSelectProductHash.each do |product_id, value|
      product = Product.shop(current_user).find(product_id.to_s)
      @full_reduction.gifts_product_ids << {:product_id => product_id.to_s, :product_name => product.title, :quantity => value}
      product.gift_full_reduction_ids << @full_reduction.id.to_s
      begin
        product.shop(current_user).save
      rescue
      end
    end
    
    @full_reduction.createUserInfo = current_user.userinfo if current_user.userinfo.present?
    respond_to do |format|
      if @full_reduction.save
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
    @update_full_reduction = FullReduction.new(full_reduction_params)
    @selectProductHash = eval(params[:selectProductHash] || "{}")
    @giftSelectProductHash = eval(params[:giftSelectProductHash] || "{}")
    @selectCouponHash = eval(params[:selectCouponHash] || "{}")
    #清除没有选择的优惠券与满减活动的关联信息
    if "3" == @full_reduction.preferential_way
      @full_reduction.coupon_infos.each do |ci|
        if @selectCouponHash[ci[:coupon_id].to_sym] == ci[:quantity]
          @selectCouponHash.delete(ci[:coupon_id].to_sym)
        else
          @full_reduction.coupon_infos.delete(ci)
          begin
            c = Coupon.find(ci[:coupon_id])
            c.full_reduction_ids.delete(@full_reduction.id.to_s)
            c.save
          rescue
          end
        end
      end
    end
    #设置赠送优惠券列表
    @selectCouponHash.each do |coupon_id, value|
      coupon = Coupon.find(coupon_id.to_s)
      @full_reduction.coupon_infos << {:coupon_id => coupon_id.to_s, :quantity => value}
      coupon.full_reduction_ids << @full_reduction.id.to_s
      coupon.save
    end
    Rails.logger.info "length ===#{@full_reduction.participateProducts(current_user).size}"

    #清除商品与满减活动的关联信息
    @full_reduction.participate_product_ids.each do |pid|
      if @selectProductHash.has_key?(pid.to_sym)
        @selectProductHash.delete(pid.to_sym)
      else
        @full_reduction.participate_product_ids.delete(pid)
        begin
          p = Product.shop(current_user).find(pid)
          p.full_reduction_id = nil
          p.tags_array.delete(@full_reduction.tag)
          p.shop(current_user).save
        rescue
        end
      end
    end
    #设置参与的商品列表
    @selectProductHash.each do |product_id, value|
      @full_reduction.participate_product_ids << product_id.to_s
      product = Product.shop(current_user).find(product_id.to_s)
      raise "该商品已经参与其他的满减活动了" if product.full_reduction_id.present?
      product.full_reduction_id = @full_reduction.id.to_s
      if @full_reduction.tag.present?
        product.tags_array.delete(@full_reduction.tag)
        product.tags_array << @update_full_reduction.tag if @update_full_reduction.tag.present?
      else
        (product.tags.present? ? product.tags_array << @update_full_reduction.tag : product.tags = @update_full_reduction.tag) if @update_full_reduction.tag.present?
      end
      begin
        product.shop(current_user).save
      rescue
      end
    end
    #清除赠送商品与满减活动的关联信息
    if "4" == @full_reduction.preferential_way || "5" == @full_reduction.preferential_way
      @full_reduction.gifts_product_ids.each do |gp|
        Rails.logger.info "giftSelectProductHash==#{@giftSelectProductHash}"
        Rails.logger.info "giftHash=#{@giftSelectProductHash[gp[:product_id].to_sym]}==quantity=#{gp[:quantity]}"
        if @giftSelectProductHash[gp[:product_id].to_sym] == gp[:quantity]
          @giftSelectProductHash.delete(gp[:product_id].to_sym)
        else
          @full_reduction.gifts_product_ids.delete(gp)
          begin
            p = Product.shop(current_user).find(gp[:product_id])
            p.gift_full_reduction_ids.delete(@full_reduction.id.to_s)
            p.shop(current_user).save
          rescue
          end
        end
      end
    end
    Rails.logger.info "each == @giftSelectProductHash =#{@giftSelectProductHash}"
    #设置赠送的商品列表
    @giftSelectProductHash.each do |product_id, value|
      product = Product.shop(current_user).find(product_id.to_s)
      @full_reduction.gifts_product_ids << {:product_id => product_id.to_s, :product_name => product.title, :quantity => value}
      product.gift_full_reduction_ids << @full_reduction.id.to_s if !product.gift_full_reduction_ids.include?(@full_reduction.id.to_s)
      begin
        product.shop(current_user).save
      rescue
      end
    end
    
    respond_to do |format|
      if @full_reduction.update(full_reduction_params)
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
    #清除优惠券与满减活动的关联信息
    @full_reduction.coupons.each do |c|
      c.full_reduction_ids.delete(@full_reduction.id.to_s)
      c.save
    end
    #清除商品与满减活动的关联信息
    @full_reduction.participateProducts(current_user).each do |p|
      p.full_reduction_id = nil
      p.tags_array.delete(@full_reduction.tag)
      begin
        p.shop(current_user).save
      rescue
      end
    end
    #清除赠送商品与满减活动的关联信息
    @full_reduction.gifts(current_user).each do |p|
      p.gift_full_reduction_ids.delete(@full_reduction.id.to_s)
      begin
        p.shop(current_user).save
      rescue
      end
    end
    @full_reduction.destroy
    respond_to do |format|
      format.html { redirect_to "#{full_reductions_url}?preferential_way=#{@full_reduction.preferential_way}" }
      format.json { head :no_content }
      format.js { render_js full_reductions_path(:preferential_way => @full_reduction.preferential_way) }
    end
  end

  def loadProducts
    @products = Product.all.page params[:page]
    
    respond_to do |format|
      format.js
    end
  end
  
  private

    def buildHash
      @aasmState = Hash.new
      @aasmState[:noBeging] = "未开始"
      @aasmState[:beging] = "正在进行"
      @aasmState[:end] = "已结束"
    end
    
    def get_products
      @state = State.find_by(:value => "online")
      @products = Product.shop(current_user).where(:state_id => @state.id, :full_reduction_id => nil)
      @giftProducts = Product.shop(current_user).where(:state_id => @state.id)
    end
    
    def get_coupons
      @coupons = Coupon.where({:aasm_state => "beging", :userinfo_id => current_user.userinfo, :quantity => {"$gt" => 0}})
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
