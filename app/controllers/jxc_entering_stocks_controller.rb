class JxcEnteringStocksController < ApplicationController
  before_action :set_jxc_entering_stock, only: [:show, :edit, :update, :destroy,:audit]

  # @current=1
  # GET /jxc_entering_stocks
  # GET /jxc_entering_stocks.json
  def index
    # @jxc_entering_stocks = JxcEnteringStock.includes(:jxc_storage).includes(:jxc_bill_details).includes(:handler).page(params[:page])
    # if @jxc_entering_stocks.present?
    #   @jxc_entering_stock = @jxc_entering_stocks[0]
    # else
    #   @jxc_entering_stock = JxcEnteringStock.new
    # end
    @jxc_entering_stock=JxcEnteringStock.new
    @jxc_entering_stock.enteringstock_no= set_enteringstock_no
    @jxc_entering_stock.creator= current_user

    # @jxc_bill_detail=JxcBillDetail.new
  end

  # GET /jxc_entering_stocks/new
  def new
    @jxc_entering_stock = JxcEnteringStock.new
    @jxc_entering_stock.enteringstock_no= set_enteringstock_no
    @jxc_entering_stock.creator= current_user
    # @jxc_bill_detail=JxcBillDetail.new
  end

  # GET /jxc_entering_stocks/1
  # GET /jxc_entering_stocks/1.json
  def show
    # @jxc_entering_stock =JxcEnteringStock.find(params[:id])
    # @jxc_bill_details=@jxc_entering_stock.jxc_bill_details
  end

  def bill_detail

  end

  # GET /jxc_entering_stocks/1/edit
  def edit
  end

  # POST /jxc_entering_stocks
  # POST /jxc_entering_stocks.json
  def create
    p "===========================#{params}"
    @jxc_entering_stock = JxcEnteringStock.new(jxc_entering_stock_params)
    # for p in params[:jxc_entering_stock][:jxc_bill_details]
    #   @jxc_entering_stock.jxc_bill_details<< JxcBillDetail.find(p)
    # end
    # @jxc_entering_stock.jxc_bill_details=params[:jxc_entering_stock][:jxc_bill_details]
    @jxc_entering_stock.creator=current_user

    respond_to do |format|
      if @jxc_entering_stock.save
        format.html { redirect_to :back, notice: 'Jxc accounting voucher was successfully created.' }
        format.json { render json: nil, status: :ok}
      else
        # format.html
        format.json { render json: @jxc_entering_stock.errors, status: :unprocessable_entity }
      end
    end
  end

  # def bill_detail_index
  #   #p params[:jxc_entering_stock_id]
  #   @jxc_bill_details = JxcBillDetail.includes(:product).where({:jxc_entering_stock_id => params[:stock_id], :creator => current_user}).page(params[:page]).per(params[:rows])
  #   # p @jxc_bill_details.size
  #   render "bill_detail_index"
  # end
  #
  #
  # # POST /jxc_entering_stocks
  # # POST /jxc_entering_stocks.json
  # def bill_detail_create
  #   @jxc_bill_detail = JxcBillDetail.new(jxc_bill_detail_params)
  #   @jxc_bill_detail.jxc_entering_stock_id=params[:jxc_entering_stock_id]
  #   respond_to do |format|
  #     if @jxc_bill_detail.save
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
    respond_to do |format|
      if @jxc_entering_stock.update(jxc_entering_stock_params)
        #format.html { redirect_to @jxc_entering_stock, notice: 'Jxc entering stock was successfully updated.' }
        format.json { render json: @jxc_entering_stock, status: :ok, location: @jxc_entering_stock }
      else
        ##format.html { render :edit }
        format.json { render json: @jxc_entering_stock.errors, status: :unprocessable_entity }
      end
    end
  end


  def audit
    respond_to do |format|
      if @jxc_entering_stock.change_state(params[:state])
        format.html { redirect_to :back, notice: '成功！' }
        format.json { render json: @jxc_entering_stock, status: :ok, location: @jxc_entering_stock }
      else
        format.html { redirect_to :back, notice: '失败！'  }
        format.json { render json: @jxc_entering_stock.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /jxc_entering_stocks/1
  # DELETE /jxc_entering_stocks/1.json
  def destroy
    @jxc_entering_stock.destroy
    respond_to do |format|
      format.html { redirect_to jxc_entering_stocks_url, notice: 'Jxc entering stock was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def prev
    p "prev #{params}"
    begin
      @jxc_entering_stock = JxcEnteringStock.find_by(:sort => params[:no].to_i > 1 ? params[:no].to_i - 1 : 1)
    rescue
      @jxc_entering_stock = JxcEnteringStock.new
      @jxc_entering_stock.enteringstock_no= set_enteringstock_no
      @jxc_entering_stock.creator= current_user
    end
    render "jxc_entering_stocks/index.html.haml"
  end

  def next
    p params[:no]
    begin
      @jxc_entering_stock = JxcEnteringStock.find_by(:sort => params[:no].to_i + 1)
    rescue
      @jxc_entering_stock = JxcEnteringStock.new
      @jxc_entering_stock.enteringstock_no= set_enteringstock_no
      @jxc_entering_stock.creator= current_user
    end
    render "jxc_entering_stocks/index.html.haml"
  end

  # # DELETE /jxc_entering_stocks/1
  # # DELETE /jxc_entering_stocks/1.json
  # def bill_detail_destroy
  #   @jxc_bill_detail.destroy
  #   respond_to do |format|
  #     format.json { head :no_content, status: :ok }
  #   end
  # end



  private
  # def set_jxc_bill_detail
  #   @jxc_bill_detail = JxcBillDetail.find(params[:id])
  # end

  #Use callbacks to share common setup or constraints between actions.
  def set_enteringstock_no
    t=Time.now.strftime("%Y%m%d-%H%M%S")
    r=rand(999999)
   "QCRKD-"+t+"-"+r.to_s
  end
  def set_jxc_entering_stock
    id=params[:id]||params[:jxc_entering_stock_id]
    @jxc_entering_stock = JxcEnteringStock.find(id)
    # end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def jxc_entering_stock_params
    params.require(:jxc_entering_stock).permit(:id, :jxc_storage, :handler, :remark,:aasm_state,:enteringstock_no)
  end

  # def jxc_bill_detail_params
  #   params.permit(:product_id, :unit, :count, :amount, :purchase_price, :remark)
  # end
end
