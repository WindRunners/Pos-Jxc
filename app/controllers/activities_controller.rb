class ActivitiesController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :getHotProducts, only: [:fullReductions, :coupons, :promotions, :discount, :promotionDiscount]

  def fullReductions
    @platform = params[:platform]
    begin
      @fullReduction = FullReduction.find_by(:id => params[:full_reduction_id], :aasm_state => "beging", :userinfo_id => params[:userinfo_id])
      @products = @fullReduction.participateProducts
    rescue
    end
    if @fullReduction.present?
      case @fullReduction.preferential_way
        when "4" then
          @gift_count = 0
          @fullReduction.gifts_product_ids.each { |pinfo| @gift_count += pinfo["quantity"].to_i }
          render :buyGift, :layout => false
        when "1" then render :layout => false
        else
          render :fullGift, :layout => false
      end
    else
      render :layout => false
    end
  end

  def fullGift

  end

  def buyGift

  end

  def coupons
    @platform = params[:platform]
    begin
      @coupons = Coupon.where(:aasm_state => "beging", :userinfo_id => params[:userinfo_id], :quantity => {"$gt" => 0})
    rescue
    end
    render :layout => false
  end

  def promotions
    @platform = params[:platform]
    @products = Array.new
    begin
      @promotions = PromotionDiscount.where(:aasm_state => "beging", :userinfo_id => params[:userinfo_id], :type => "1")
      @products = @promotions[0].participateProducts if 0 < @promotions.count
    rescue
    end
    render :layout => false
  end

  def discount
    @platform = params[:platform]
    @products = Array.new
    begin
      @discounts = PromotionDiscount.where(:aasm_state => "beging", :userinfo_id => params[:userinfo_id], :type => "0")
      @products = @discounts[0].participateProducts if 0 < @discounts.count
    rescue
    end
    render :layout => false
  end

  def promotionDiscount
    @platform = params[:platform]
    begin
      promotionDiscount = PromotionDiscount.find_by(:id => params[:promotion_discount_id],:aasm_state => "beging", :userinfo_id => params[:userinfo_id])
      @products = promotionDiscount.participateProducts
    rescue
    end
    render :promotions, :layout => false
  end

  def skipe_one_index
    @platform = params[:platform]
    @current_userinfo = Userinfo.find(params[:id])
    @TimeArray = PanicBuying.where(:userinfo => @current_userinfo).order(:beginTime => :asc).pluck(:beginTime,:endTime)
    begin
      @panic_buying = PanicBuying.find_by(:userinfo => @current_userinfo,:state => 1)
      @products = @panic_buying.products
    rescue
      @products = []
    end


    respond_to do |format|
      format.html { render :partial => "skipe_01_index", :layout => false }
    end
  end


  def skipe_one_search

    @current_userinfo = Userinfo.find(params[:userinfo_id])
    parm = Hash.new
    parm[:userinfo] = @current_userinfo

    if !params[:beginTime].nil?
      parm[:beginTime] = params[:beginTime]
    end

    if !params[:endTime].nil?
      parm[:endTime] = params[:endTime]
    end

    begin
      @panic_buying = PanicBuying.find_by(parm)
      @products = @panic_buying.products
    rescue
      @products = []
    end


    respond_to do |format|
      format.html { render :partial => "skipe_01_product", :layout => false }
    end
  end

  private

    def getHotProducts
      @hotProducts = Product.shop_id(params[:userinfo_id]).limit(10).order_by(:sale_count => :desc)
    end
end
