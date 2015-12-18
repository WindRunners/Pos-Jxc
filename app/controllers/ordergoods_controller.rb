class OrdergoodsController < ApplicationController
  before_action :set_ordergood, only: [:show, :edit, :update, :destroy]

  # GET /ordergoods
  # GET /ordergoods.json
  def index
    @ordergoods = Ordergood.all
  end

  # GET /ordergoods/1
  # GET /ordergoods/1.json
  def show
  end

  # GET /ordergoods/new
  def new
    @ordergood = Ordergood.new

    @product = Product.find_by(:name => "测试商品")
    @ordergood.product = @product
    puts @ordergood.product.name
  end

  # GET /ordergoods/1/edit
  def edit
  end

  # POST /ordergoods
  # POST /ordergoods.json
  def create
    @ordergood = Ordergood.new(ordergood_params)


    respond_to do |format|
      if @ordergood.save(false)
        format.html { redirect_to @ordergood, notice: 'Ordergood was successfully created.' }
        format.json { render :show, status: :created, location: @ordergood }
      else
        format.html { render :new }
        format.json { render json: @ordergood.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ordergoods/1
  # PATCH/PUT /ordergoods/1.json
  def update
    respond_to do |format|
      if @ordergood.update(ordergood_params)
        format.html { redirect_to @ordergood, notice: 'Ordergood was successfully updated.' }
        format.json { render :show, status: :ok, location: @ordergood }
      else
        format.html { render :edit }
        format.json { render json: @ordergood.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ordergoods/1
  # DELETE /ordergoods/1.json
  def destroy
    @ordergood.destroy
    respond_to do |format|
      format.html { redirect_to ordergoods_url, notice: 'Ordergood was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ordergood
      @ordergood = Ordergood.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ordergood_params
      params.require(:ordergood).permit(:product, :quantity)
    end
end
