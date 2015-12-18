class CarousController < ApplicationController
  before_action :set_carou, only: [:show, :edit, :update, :destroy]

  # GET /carous
  # GET /carous.json
  def index
    @carous = Carou.carouCache
  end

  # GET /carous/1
  # GET /carous/1.json
  def show
  end

  # GET /carous/new
  def new
    @carou = Carou.new
  end

  # GET /carous/1/edit
  def edit
  end

  # POST /carous
  # POST /carous.json
  def create
    @carou = Carou.new(carou_params)

    respond_to do |format|
      if @carou.save
        format.html { redirect_to @carou, notice: 'Carou was successfully created.' }
        format.json { render :show, status: :created, location: @carou }
      else
        format.html { render :new }
        format.json { render json: @carou.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /carous/1
  # PATCH/PUT /carous/1.json
  def update
    respond_to do |format|
      if @carou.update(carou_params)
        format.html { redirect_to @carou, notice: 'Carou was successfully updated.' }
        format.json { render :show, status: :ok, location: @carou }
      else
        format.html { render :edit }
        format.json { render json: @carou.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /carous/1
  # DELETE /carous/1.json
  def destroy
    @carou.destroy
    respond_to do |format|
      format.html { redirect_to carous_url, notice: 'Carou was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_carou
      @carou = Carou.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def carou_params
      params[:carou]
    end
end
