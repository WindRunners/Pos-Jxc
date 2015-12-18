class GiftBagsController < ApplicationController
  before_action :set_gift_bag, only: [:show, :edit, :update, :destroy]

  # GET /gift_bags
  # GET /gift_bags.json
  def index

    set_import_bag

    receiver_mobile = params[:receiver_mobile]
    sign_status = params[:sign_status]

    whereParams = {}
    whereParams['receiver_mobile'] = /#{receiver_mobile}/ if receiver_mobile.present?
    whereParams['sign_status'] = #{sign_status} if sign_status.present?
    @gift_bags = @import_bag.gift_bags.where(whereParams).page(params[:page])
  end

  # GET /gift_bags/1
  # GET /gift_bags/1.json
  def show
  end

  # GET /gift_bags/new
  def new
    @gift_bag = GiftBag.new
  end

  # GET /gift_bags/1/edit
  def edit
  end

  # POST /gift_bags
  # POST /gift_bags.json
  def create
    @gift_bag = GiftBag.new(gift_bag_params)

    respond_to do |format|
      if @gift_bag.save
        format.html { redirect_to @gift_bag, notice: 'Gift bag was successfully created.' }
        format.json { render :show, status: :created, location: @gift_bag }
      else
        format.html { render :new }
        format.json { render json: @gift_bag.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /gift_bags/1
  # PATCH/PUT /gift_bags/1.json
  def update
    respond_to do |format|
      if @gift_bag.update(gift_bag_params)
        format.html { redirect_to @gift_bag, notice: 'Gift bag was successfully updated.' }
        format.json { render :show, status: :ok, location: @gift_bag }
      else
        format.html { render :edit }
        format.json { render json: @gift_bag.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /gift_bags/1
  # DELETE /gift_bags/1.json
  def destroy
    @gift_bag.destroy
    respond_to do |format|
      format.html { redirect_to gift_bags_url, notice: 'Gift bag was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_gift_bag
      @gift_bag = GiftBag.find(params[:id])
    end

    # 设置导入包
    def set_import_bag
      @import_bag = ImportBag.find(params[:import_bag_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def gift_bag_params
      params.require(:gift_bag).permit(:receiver_mobile, :sign_status, :expir_days, :expiry_time, :content, :memo)
    end
end
