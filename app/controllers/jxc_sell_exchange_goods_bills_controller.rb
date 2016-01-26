class JxcSellExchangeGoodsBillsController < ApplicationController
  before_action :set_jxc_sell_exchange_goods_bill, only: [:show, :edit, :update, :destroy]

  def index
    @jxc_sell_exchange_goods_bills = JxcSellExchangeGoodsBill.all
  end

  def show
  end

  def new
    @jxc_sell_exchange_goods_bill = JxcSellExchangeGoodsBill.new
  end

  def edit
  end

  def create
    @jxc_sell_exchange_goods_bill = JxcSellExchangeGoodsBill.new(jxc_sell_exchange_goods_bill_params)

    respond_to do |format|
      if @jxc_sell_exchange_goods_bill.save
        format.html { redirect_to @jxc_sell_exchange_goods_bill, notice: 'Jxc sell exchange goods bill was successfully created.' }
        format.json { render :show, status: :created, location: @jxc_sell_exchange_goods_bill }
      else
        format.html { render :new }
        format.json { render json: @jxc_sell_exchange_goods_bill.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @jxc_sell_exchange_goods_bill.update(jxc_sell_exchange_goods_bill_params)
        format.html { redirect_to @jxc_sell_exchange_goods_bill, notice: 'Jxc sell exchange goods bill was successfully updated.' }
        format.json { render :show, status: :ok, location: @jxc_sell_exchange_goods_bill }
      else
        format.html { render :edit }
        format.json { render json: @jxc_sell_exchange_goods_bill.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @jxc_sell_exchange_goods_bill.destroy
    respond_to do |format|
      format.html { redirect_to jxc_sell_exchange_goods_bills_url, notice: 'Jxc sell exchange goods bill was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  def set_jxc_sell_exchange_goods_bill
    @jxc_sell_exchange_goods_bill = JxcSellExchangeGoodsBill.find(params[:id])
  end

  def jxc_sell_exchange_goods_bill_params
    params.require(:jxc_sell_exchange_goods_bill).permit(:bill_no, :customize_bill_no, :collection_date, :exchange_date, :current_collection, :remark, :total_amount, :discount, :discount_amount, :exchange_gap, :bill_status)
  end
end
