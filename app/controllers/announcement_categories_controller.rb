class AnnouncementCategoriesController < ApplicationController
  before_action :set_announcement_category, only: [:show, :edit, :update, :destroy]

  # GET /announcement_categories
  # GET /announcement_categories.json
  def index
    @announcement_categories = AnnouncementCategory.all.page(params[:page]).order('created_at DESC')
  end

  # GET /announcement_categories/1
  # GET /announcement_categories/1.json
  def show
  end

  # GET /announcement_categories/new
  def new
    @announcement_category = AnnouncementCategory.new

  end

  # GET /announcement_categories/1/edit
  def edit
  end

  # POST /announcement_categories
  # POST /announcement_categories.json
  def create
    @announcement_category = AnnouncementCategory.new(announcement_category_params)

    respond_to do |format|
      if @announcement_category.save
        # format.html { redirect_to @announcement_category, notice: 'Announcement category was successfully created.' }
        format.js { render_js announcement_categories_path }
        format.json { render :show, status: :created, location: @announcement_category }
      else
        format.html { render :new }
        format.js
        format.json { render json: @announcement_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /announcement_categories/1
  # PATCH/PUT /announcement_categories/1.json
  def update
    respond_to do |format|
      if @announcement_category.update(announcement_category_params)
        # format.html { redirect_to @announcement_category, notice: 'Announcement category was successfully updated.' }
        format.js { render_js announcement_categories_path }
        format.json { render :show, status: :ok, location: @announcement_category }
      else
        format.html { render :edit }
        format.js { render_js announcement_categories_path }
        format.json { render json: @announcement_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /announcement_categories/1
  # DELETE /announcement_categories/1.json
  def destroy
    @announcement_category.destroy
    respond_to do |format|
      format.js { render_js announcement_categories_path}
      # format.html { redirect_to announcement_categories_url, notice: 'Announcement category was successfully destroyed.' }
      format.json { head :no_content }
    end
  end


  private
  # Use callbacks to share common setup or constraints between actions.
  def set_announcement_category
    @announcement_category = AnnouncementCategory.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def announcement_category_params
    params.require(:announcement_category).permit(:description, :name, :sequence)
  end
end
