class ExpiredWarningProductsController < ApplicationController
  before_action :set_expired_warning_product, only: [:show, :edit, :update, :destroy]

  # GET /expired_warning_products
  # GET /expired_warning_products.json
  def index
    @expired_warning_products = ExpiredWarningProduct.all
  end

  # GET /expired_warning_products/1
  # GET /expired_warning_products/1.json
  def show
  end

  # GET /expired_warning_products/new
  def new
    @expired_warning_product = ExpiredWarningProduct.new
  end

  # GET /expired_warning_products/1/edit
  def edit
  end

  # POST /expired_warning_products
  # POST /expired_warning_products.json
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

  # PATCH/PUT /expired_warning_products/1
  # PATCH/PUT /expired_warning_products/1.json
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

  # DELETE /expired_warning_products/1
  # DELETE /expired_warning_products/1.json
  def destroy
    @expired_warning_product.destroy
    respond_to do |format|
      format.html { redirect_to expired_warning_products_url, notice: 'Expired warning product was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_expired_warning_product
      @expired_warning_product = ExpiredWarningProduct.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def expired_warning_product_params
      params[:expired_warning_product]
    end
end
