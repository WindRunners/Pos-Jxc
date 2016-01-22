class CardBagsController < ApplicationController
  before_action :set_card_bag, only: [:show, :edit, :update, :destroy]
  skip_before_action :authenticate_user!, only: [:register, :share_time_check, :share]

  # GET /card_bags
  # GET /card_bags.json
  def index
    @card_bags = CardBag.all
  end

  # GET /card_bags/1
  # GET /card_bags/1.json
  def show
  end

  # GET /card_bags/new
  def new
    @card_bag = CardBag.new
  end

  # GET /card_bags/1/edit
  def edit
  end

  # POST /card_bags
  # POST /card_bags.json
  def create
    @card_bag = CardBag.new(card_bag_params)

    respond_to do |format|
      if @card_bag.save
        format.html { redirect_to @card_bag, notice: 'Card bag was successfully created.' }
        format.json { render :show, status: :created, location: @card_bag }
      else
        format.html { render :new }
        format.json { render json: @card_bag.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /card_bags/1
  # PATCH/PUT /card_bags/1.json
  def update
    respond_to do |format|
      if @card_bag.update(card_bag_params)
        format.html { redirect_to @card_bag, notice: 'Card bag was successfully updated.' }
        format.json { render :show, status: :ok, location: @card_bag }
      else
        format.html { render :edit }
        format.json { render json: @card_bag.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /card_bags/1
  # DELETE /card_bags/1.json
  def destroy
    @card_bag.destroy
    respond_to do |format|
      format.html { redirect_to card_bags_url, notice: 'Card bag was successfully destroyed.' }
      format.json { head :no_content }
    end
  end






  private
    # Use callbacks to share common setup or constraints between actions.
    def set_card_bag
      @card_bag = CardBag.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def card_bag_params
      params.require(:card_bag).permit(:customer_id, :status, :register_customer_count, :login_customer_count, :source)
    end
end
