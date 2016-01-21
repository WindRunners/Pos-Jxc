class JxcProductClassifyStandardsController < ApplicationController
  before_action :set_jxc_product_classify_standard, only: [:show, :edit, :update, :destroy]

  def index
    @jxc_product_classify_standards = JxcProductClassifyStandard.page(params[:page]).per(10)
  end

  def show
  end

  def new
    @jxc_product_classify_standard = JxcProductClassifyStandard.new
  end

  def edit
  end

  def create
    @jxc_product_classify_standard = JxcProductClassifyStandard.new(jxc_product_classify_standard_params)
    if @jxc_product_classify_standard.save
      render json: @jxc_product_classify_standard
    end
  end

  def update
    respond_to do |format|
      if @jxc_product_classify_standard.update(jxc_product_classify_standard_params)
        format.html { redirect_to @jxc_product_classify_standard, notice: 'Jxc product classify standard was successfully updated.' }
        format.json { render :show, status: :ok, location: @jxc_product_classify_standard }
      else
        format.html { render :edit }
        format.json { render json: @jxc_product_classify_standard.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @jxc_product_classify_standard.destroy
    respond_to do |format|
      format.html { redirect_to jxc_product_classify_standards_url, notice: 'Jxc product classify standard was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  def set_jxc_product_classify_standard
    @jxc_product_classify_standard = JxcProductClassifyStandard.find(params[:id])
  end

  def jxc_product_classify_standard_params
    params.require(:jxc_product_classify_standard).permit(:class_name, :standard)
  end
end
