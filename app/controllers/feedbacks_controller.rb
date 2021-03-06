class FeedbacksController < ApplicationController
  before_action :set_feedback, only: [:show, :edit, :update, :destroy]

  # GET /feedbacks
  # GET /feedbacks.json
  def index

    real_name = params[:real_name]
    mobile = params[:mobile]
    whereParams = {}  #查询条件
    whereParams['real_name'] = /#{real_name}/ if real_name.present?
    whereParams['mobile'] = /#{mobile}/ if mobile.present?
    Rails.logger.info whereParams
    @feedbacks = Feedback.where(whereParams).page(params[:page])
  end

  # GET /feedbacks/1
  # GET /feedbacks/1.json
  def show
  end

  # GET /feedbacks/new
  def new
    @feedback = Feedback.new
  end

  # GET /feedbacks/1/edit
  def edit
  end

  # POST /feedbacks
  # POST /feedbacks.json
  def create
    @feedback = Feedback.new(feedback_params)

    respond_to do |format|
      if @feedback.save
        # format.js { render_js feedbacks_path, notice: 'Feedback was successfully created.' }
        # format.html { redirect_to @feedback, notice: 'Feedback was successfully created.' }
        # format.json { render :show, status: :created, location: @feedback }
        # format.json { render json: get_render_json(1,nil,feedbacks_path) }
        format.json { render json: get_render_common_json(@feedback,feedbacks_path(@feedback)) }
      else
        # format.html { render :new }
        # format.json { render json: @feedback.errors, status: :unprocessable_entity }
        # format.json { render json: get_render_json(0,@feedback.errors.messages) }
        format.json { render json: get_render_common_json(@feedback) }
      end
    end
  end

  # PATCH/PUT /feedbacks/1
  # PATCH/PUT /feedbacks/1.json
  def update
    respond_to do |format|
      if @feedback.update(feedback_params)
        # format.js { render_js feedbacks_path, notice: 'Feedback was successfully updated.' }
        # format.html { redirect_to @feedback, notice: 'Feedback was successfully updated.' }
        # format.json { render :show, status: :ok, location: @feedback }
        # format.json { render json: get_render_json(1,nil,feedbacks_path) }
        format.json { render json: get_render_common_json(@feedback,feedbacks_path(@feedback)) }
      else
        # format.html { render :edit }
        # format.json { render json: @feedback.errors, status: :unprocessable_entity }
        # format.json { render json: get_render_json(0,@feedback.errors.messages) }
        format.json { render json: get_render_common_json(@feedback) }
      end
    end
  end

  # DELETE /feedbacks/1
  # DELETE /feedbacks/1.json
  def destroy
    @feedback.destroy
    respond_to do |format|
      format.js { render_js feedbacks_path, notice: 'Feedback was successfully destroyed.' }
      # format.html { redirect_to feedbacks_url, notice: 'Feedback was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_feedback
    @feedback = Feedback.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def feedback_params
    params.require(:feedback).permit(:mobile, :real_name, :feedback_content)
  end
end
