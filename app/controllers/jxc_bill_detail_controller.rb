class JxcBillDetailController < ApplicationController

  before_action :set_jxc_bill_detail, only: [:show, :edit, :update, :destroy]

  # GET /jxc_entering_stocks
  # GET /jxc_entering_stocks.json
  def index
    @jxc_bill_details=JxcBillDetail.where(:entering_stock_id => params[:stock_id])

    # @jxc_entering_stocks = JxcEnteringStock.includes(:jxc_storage).includes(:jxc_bill_details).includes(:handler).page(params[:page])
    # if @jxc_entering_stocks.present?
    #   @jxc_entering_stock = @jxc_entering_stocks[0]
    # else
    #   @jxc_entering_stock = JxcEnteringStock.new
    # end
  end

  # GET /jxc_entering_stocks/new
  def new
    @jxc_bill_detail=JxcBillDetail.new
  end

  # GET /jxc_entering_stocks/1
  # GET /jxc_entering_stocks/1.json
  def show
  end

  # GET /jxc_entering_stocks/1/edit
  def edit
  end

  # POST /jxc_entering_stocks
  # POST /jxc_entering_stocks.json
  def create

    p "pd==========================#{params[:postData].as_json}"
    for pd in params[:postData]

      @jxc_bill_detail = JxcBillDetail.new
      @jxc_bill_detail.count=pd[1][:count]
      @jxc_bill_detail.price=pd[1][:price].to_f
      @jxc_bill_detail.amount=pd[1][:amount].to_f
      @jxc_bill_detail.resource_product_id=pd[1][:product_id]
      @jxc_bill_detail.remark=pd[1][:remark]
      @jxc_bill_detail.entering_stock_id=pd[1][:stock_id]
      @jxc_bill_detail.unit=pd[1][:unit]
      # @jxc_bill_detail[:creator]=current_user
      p "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#{@jxc_bill_detail.to_json}"
      @jxc_bill_detail.save
    end
    respond_to do |format|
      # format.html { redirect_to @jxc_bill_detail, notice: 'Jxc entering stock was successfully created.' }
      format.json { render json:nil, status: :ok}
    end
  end

  # def bill_detail_index
  #   #p params[:jxc_entering_stock_id]
  #   # @jxc_bill_details = JxcBillDetail(current_user).includes(:product).where({:jxc_entering_stock_id=>params[:stock_id],:creator=>current_user}).page(params[:page]).per(params[:rows])
  #   # p @jxc_bill_details.size
  #   # render "bill_detail_index"
  # end
  #
  #
  # # POST /jxc_entering_stocks
  # # POST /jxc_entering_stocks.json
  # def bill_detail_create
  #   @jxc_bill_detail = JxcBillDetail.new(jxc_bill_detail_params)
  #   @jxc_bill_detail.jxc_entering_stock_id=params[:jxc_entering_stock_id]
  #   respond_to do |format|
  #     if @jxc_bill_detail(current_user).save
  #       #format.html { redirect_to @jxc_entering_stock, notice: 'Jxc entering stock was successfully created.' }
  #       format.json { render json: @jxc_bill_detail, status: :created }
  #     else
  #       #format.html { render :new }
  #       format.json { render json: @jxc_bill_detail.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # PATCH/PUT /jxc_entering_stocks/1
  # PATCH/PUT /jxc_entering_stocks/1.json
  def update
    # respond_to do |format|
    #   if @jxc_entering_stock(current_user).update(jxc_entering_stock_params)
    #     #format.html { redirect_to @jxc_entering_stock, notice: 'Jxc entering stock was successfully updated.' }
    #     format.json { render json: @jxc_entering_stock, status: :ok, location: @jxc_entering_stock }
    #   else
    #     ##format.html { render :edit }
    #     format.json { render json: @jxc_entering_stock.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # DELETE /jxc_entering_stocks/1
  # DELETE /jxc_entering_stocks/1.json
  def destroy
    # @jxc_entering_stock(current_user).destroy
    # respond_to do |format|
    #   format.html { redirect_to jxc_entering_stocks_url, notice: 'Jxc entering stock was successfully destroyed.' }
    #   format.json { head :no_content }
    # end
  end


  private
  def set_jxc_bill_detail
    @jxc_bill_detail = JxcBillDetail.find(params[:id])
  end

  def jxc_bill_detail_params
    params.permit(:product_id, :unit, :count, :amount, :purchase_price, :remark)
  end
end
