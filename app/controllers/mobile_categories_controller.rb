class MobileCategoriesController < ApplicationController
  before_action :set_category, only: [:show, :edit, :update, :destroy]

  # GET /categories
  # GET /categories.json
  def index
    @categories = current_user.userinfo.mobile_categories
  end

  # GET /categories/1
  # GET /categories/1.json
  def show
  end

  # GET /categories/new
  def new
    @category = current_user.userinfo.mobile_categories.build
  end

  # GET /categories/1/edit
  def edit
  end

  # POST /categories
  # POST /categories.json
  def create
    @category = MobileCategory.new(category_params)

    @category.userinfo = current_user.userinfo

    respond_to do |format|
      if @category.save
        format.html { redirect_to mobile_categories_path, notice: '添加成功' }
        format.json { render :show, status: :created, location: @category }
        format.js { render_js mobile_categories_path }
      else
        format.html { render :new }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /categories/1
  # PATCH/PUT /categories/1.json
  def update
    title_changed = params[:mobile_category][:title].present? and params[:mobile_category][:title] != @category.title

    num_changed = params[:mobile_category][:num].present? and params[:mobile_category][:num] != @category.num

    respond_to do |format|
      if @category.update(category_params)

        if title_changed
          @category.products.update_all({mobile_category_name:@category.title})
        end

        if num_changed
          @category.products.update_all({mobile_category_num:@category.num})
        end

        format.html { redirect_to mobile_categories_url, notice: '更新成功.' }
        format.json { respond_with_bip(@category) }
        format.js { render_js mobile_categories_url }
      else
        format.html { render :edit }
        format.json { respond_with_bip(@category) }
      end
    end
  end

  # DELETE /categories/1
  # DELETE /categories/1.json
  def destroy
    if @category.product_count > 0
      redirect_to mobile_categories_url, notice: '有商品的分类不能删除'
      return
    end

    @category.destroy
    respond_to do |format|
      format.html { redirect_to mobile_categories_url, notice: '删除成功.' }
      format.json { head :no_content }
      format.js { render_js mobile_categories_url }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_category
      @category = MobileCategory.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def category_params
      params.require(:mobile_category).permit(:title, :num)
    end
end
