class CarouselsController < ApplicationController
  before_action :set_carousel, only: [:show, :edit, :update, :destroy]

  # GET /carousels
  # GET /carousels.json
  def index
      @carousels = Carousel.all
  end

  # GET /carousels/1
  # GET /carousels/1.json
  def show
    # @carruse = CarouselAsset.all
    #@carruselAssets.path if carouselAssets.present?
  end

  # GET /carousels/new
  def new
    @carousel = Carousel.new
  end

  # GET /carousels/1/edit
  def edit
  end

  # POST /carousels
  # POST /carousels.json
  def create
    @carousel = Carousel.new(carousel_params)
    @carousel.user = current_user
    respond_to do |format|
      if @carousel.save
        format.html { redirect_to @carousel, notice: 'Carousel was successfully created.' }
        format.json { render :show, status: :created, location: @carousel }
        format.js{render_js carousels_url}
      else
        format.html { render :new }
        format.json { render json: @carousel.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /carousels/1
  # PATCH/PUT /carousels/1.json
  def update
    @updateCarouel = Carousel.new(carousel_params)
    respond_to do |format|
      if @carousel.update(carousel_params)
        format.html { redirect_to @carousel, notice: 'Carousel was successfully updated.' }
        format.json { render :show, status: :ok, location: @carousel }
        format.js{render_js carousels_url}
      else
        format.html { render :edit }
        format.json { render json: @carousel.errors, status: :unprocessable_entity }
      end
    end
  end

  def upload
    @carousel = Carousel.find(params[:carousel_id])

    @carousel.avatar = params[:carousel][:avatar]

    # unless asset.blank?
    #   @origin = @carousel.carouselAssets.build
    #   @origin.asset = asset
    # end

    @carousel.save
    
    respond_to do |format|
      format.js{render_js carousels_url}
      # format.js
    end
  end

  def downloadAsset
    begin
      @asset = CarouselAsset.find(params[:carousel_id])
    rescue
    end

    path = @asset.asset.path
    send_file(path)
  end

  def destroyAsset

    begin
      @asset = CarouselAsset.find(params[:carousel_id])
    rescue
    end
    @asset.destroy
    render :partial => "asset_destroy.js"
  end

  def img_url
    @carousel_asset = CarouselAsset.all
    @carousel_asset.as_json
    p @carousel_asset
  end


  # DELETE /carousels/1
  # DELETE /carousels/1.json
  def destroy
    @carousel.destroy
    respond_to do |format|
      format.html { redirect_to carousels_url, notice: 'Carousel was successfully destroyed.' }
      format.json { head :no_content }
      format.js{render_js carousels_url}
    end
  end

  def carouselAssetsFirst
    if @app_key.present?
      #@carruselAssets = CarouselAsset.all
      @carruselAssets[0].path if carouselAssets.present?
      p 'sdfas23121'
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_carousel
    @carousel = Carousel.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def carousel_params
    params.require(:carousel).permit(:area, :start_time, :end_time,:url, carouselAssets_attributes: [:asset],)
  end
end
