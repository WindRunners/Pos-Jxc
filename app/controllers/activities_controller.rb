class ActivitiesController < ApplicationController
  skip_before_action :authenticate_user!
  
  def index
    @platform = params[:platform]
    begin
      @fullReduction = FullReduction.find_by(:id => params[:full_reduction_id], :aasm_state => "beging", :userinfo_id => params[:id])
      @products = @fullReduction.participateProductsById(params[:id])

      # productsJson = {}
      # @products.each {|p| productsJson[p.id] = p}
      # gon.products = productsJson

    rescue
    end
    render :layout => false
  end

  def coupons
    @platform = params[:platform]
    begin
      @coupons = Coupon.where(:aasm_state => "beging", :userinfo_id => params[:userinfo_id])
    rescue
    end
    render :layout => false
  end

  def promotions
    @platform = params[:platform]
    @products = Array.new
    begin
      @promotions = PromotionDiscount.where(:aasm_state => "beging", :userinfo_id => params[:userinfo_id], :type => "1")
      puts "count===#{@promotions.count}"
      @products = @promotions[0].participateProducts if 0 < @promotions.count
    rescue
    end
    render :layout => false
  end

  def promotionDiscount
    @platform = params[:platform]
    begin
      promotionDiscount = PromotionDiscount.find_by(:id => params[:promotion_discount_id],:aasm_state => "beging", :userinfo_id => params[:id])
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
end
