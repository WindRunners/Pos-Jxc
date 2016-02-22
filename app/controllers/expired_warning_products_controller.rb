class ExpiredWarningProductsController < ApplicationController
  before_action :set_expired_warning_product, only: [:show, :edit, :update, :destroy]

  def index
    storage_id = params[:storage_id] || ''
    @expired_warning_products = ExpiredWarningProduct.by_storage(storage_id).order_by(:created_at => :desc).page(params[:page]).per(10)
  end

  def show
  end

  def new
    @expired_warning_product = ExpiredWarningProduct.new
  end

  def edit
  end

  def create
    @expired_warning_product = ExpiredWarningProduct.new(expired_warning_product_params)

    respond_to do |format|
      if @expired_warning_product.save
        format.html { redirect_to @expired_warning_product, notice: 'Expired warning product was successfully created.' }
        format.json { render :show, status: :created, location: @expired_warning_product }
      else
        format.html { render :new }
        format.json { render json: @expired_warning_product.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @expired_warning_product.update(expired_warning_product_params)
        format.html { redirect_to @expired_warning_product, notice: 'Expired warning product was successfully updated.' }
        format.json { render :show, status: :ok, location: @expired_warning_product }
      else
        format.html { render :edit }
        format.json { render json: @expired_warning_product.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @expired_warning_product.destroy
    respond_to do |format|
      format.html { redirect_to expired_warning_products_url, notice: 'Expired warning product was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_expired_warning_product
      @expired_warning_product = ExpiredWarningProduct.find(params[:id])
    end

    def expired_warning_product_params
      params[:expired_warning_product]
    end
end
