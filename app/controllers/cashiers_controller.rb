class CashiersController < ApplicationController
  before_action :set_cashier, only: [:show, :edit, :update, :destroy]

  # GET /cashiers
  # GET /cashiers.json
  def index
    @cashiers = Cashier.all
    @stores = current_user.stores
  end

  # GET /cashiers/1
  # GET /cashiers/1.json
  def show
  end

  # GET /cashiers/new
  def new
    @cashier = Cashier.new
  end

  # GET /cashiers/1/edit
  def edit
  end

  # POST /cashiers
  # POST /cashiers.json
  def create
    @cashier = Cashier.new(cashier_params)

    respond_to do |format|
      if @cashier.save
        format.html { redirect_to @cashier, notice: 'Cashier was successfully created.' }
        format.json { render :show, status: :created, location: @cashier }
      else
        format.html { render :new }
        format.json { render json: @cashier.errors, status: :unprocessable_entity }
      end
    end
  end

  def checkCustomer
    mobile = params[:mobile]
    @customer = Customer.find_by_mobile(params[:mobile])
    @customer = Customer.create_by_mobile(params[:mobile]) if @customer.blank?

    if @customer.present?
      respond_to do |format|
        format.json { render :json => {exists: true,
                                       id: @customer.id,
                                       integral: @customer.integral} }
      end
    else
      respond_to do |format|
        format.json { render :json => {exists: false} }
      end
    end
  end

  # PATCH/PUT /cashiers/1
  # PATCH/PUT /cashiers/1.json
  def update
    respond_to do |format|
      if @cashier.update(cashier_params)
        format.html { redirect_to @cashier, notice: 'Cashier was successfully updated.' }
        format.json { render :show, status: :ok, location: @cashier }
      else
        format.html { render :edit }
        format.json { render json: @cashier.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cashiers/1
  # DELETE /cashiers/1.json
  def destroy
    @cashier.destroy
    respond_to do |format|
      format.html { redirect_to cashiers_url, notice: 'Cashier was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_cashier
    @cashier = Cashier.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def cashier_params
    params.require(:cashier).permit(:totalPrice, :discount)
  end
end
