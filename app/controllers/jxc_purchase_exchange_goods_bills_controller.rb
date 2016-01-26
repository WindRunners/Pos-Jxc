class JxcPurchaseExchangeGoodsBillsController < ApplicationController
  before_action :set_jxc_purchase_exchange_goods_bill, only: [:show, :edit, :update, :destroy]

  def index
    @jxc_purchase_exchange_goods_bills = JxcPurchaseExchangeGoodsBill.all
  end

  def show
  end

  def new
    @jxc_purchase_exchange_goods_bill = JxcPurchaseExchangeGoodsBill.new
  end

  def edit
  end

  def create
    @jxc_purchase_exchange_goods_bill = JxcPurchaseExchangeGoodsBill.new(jxc_purchase_exchange_goods_bill_params)

    respond_to do |format|
      if @jxc_purchase_exchange_goods_bill.save
        format.html { redirect_to @jxc_purchase_exchange_goods_bill, notice: 'Jxc purchase exchange goods bill was successfully created.' }
        format.json { render :show, status: :created, location: @jxc_purchase_exchange_goods_bill }
      else
        format.html { render :new }
        format.json { render json: @jxc_purchase_exchange_goods_bill.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @jxc_purchase_exchange_goods_bill.update(jxc_purchase_exchange_goods_bill_params)
        format.html { redirect_to @jxc_purchase_exchange_goods_bill, notice: 'Jxc purchase exchange goods bill was successfully updated.' }
        format.json { render :show, status: :ok, location: @jxc_purchase_exchange_goods_bill }
      else
        format.html { render :edit }
        format.json { render json: @jxc_purchase_exchange_goods_bill.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @jxc_purchase_exchange_goods_bill.destroy
    respond_to do |format|
      format.html { redirect_to jxc_purchase_exchange_goods_bills_url, notice: 'Jxc purchase exchange goods bill was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_jxc_purchase_exchange_goods_bill
      @jxc_purchase_exchange_goods_bill = JxcPurchaseExchangeGoodsBill.find(params[:id])
    end

    def jxc_purchase_exchange_goods_bill_params
      params[:jxc_purchase_exchange_goods_bill]
    end
end
