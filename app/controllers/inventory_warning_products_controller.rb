class InventoryWarningProductsController < ApplicationController
  before_action :set_inventory_warning_product, only: [:show, :edit, :update, :destroy]

  def index
    storage_id = params[:storage_id] || ''
    if storage_id.present?
      @inventory_warning_products = InventoryWarningProduct.where(:storage_id => storage_id).order_by(:created_at => :desc).page(params[:page]).per(10)
    else
      @inventory_warning_products = InventoryWarningProduct.order_by(:created_at => :desc).page(params[:page]).per(10)
    end
  end

  def show
  end

  def new
    @inventory_warning_product = InventoryWarningProduct.new
  end

  def edit
  end

  def create
    @inventory_warning_product = InventoryWarningProduct.new(inventory_warning_product_params)

    respond_to do |format|
      if @inventory_warning_product.save
        format.html { redirect_to @inventory_warning_product, notice: 'Inventory warning product was successfully created.' }
        format.json { render :show, status: :created, location: @inventory_warning_product }
      else
        format.html { render :new }
        format.json { render json: @inventory_warning_product.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @inventory_warning_product.update(inventory_warning_product_params)
        format.html { redirect_to @inventory_warning_product, notice: 'Inventory warning product was successfully updated.' }
        format.json { render :show, status: :ok, location: @inventory_warning_product }
      else
        format.html { render :edit }
        format.json { render json: @inventory_warning_product.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @inventory_warning_product.destroy
    respond_to do |format|
      format.html { redirect_to inventory_warning_products_url, notice: 'Inventory warning product was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_inventory_warning_product
      @inventory_warning_product = InventoryWarningProduct.find(params[:id])
    end

    def inventory_warning_product_params
      params[:inventory_warning_product]
    end
end
