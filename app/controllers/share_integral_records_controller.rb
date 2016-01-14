class ShareIntegralRecordsController < ApplicationController
  before_action :set_share_integral_record, only: [:show, :edit, :update, :destroy]

  # GET /share_integral_records
  # GET /share_integral_records.json
  def index
    @share_integral_records = ShareIntegralRecord.all
  end

  # GET /share_integral_records/1
  # GET /share_integral_records/1.json
  def show
  end

  # GET /share_integral_records/new
  def new
    @share_integral_record = ShareIntegralRecord.new
  end

  # GET /share_integral_records/1/edit
  def edit
  end

  # POST /share_integral_records
  # POST /share_integral_records.json
  def create
    @share_integral_record = ShareIntegralRecord.new(share_integral_record_params)

    respond_to do |format|
      if @share_integral_record.save
        format.html { redirect_to @share_integral_record, notice: 'Share integral record was successfully created.' }
        format.json { render :show, status: :created, location: @share_integral_record }
      else
        format.html { render :new }
        format.json { render json: @share_integral_record.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /share_integral_records/1
  # PATCH/PUT /share_integral_records/1.json
  def update
    respond_to do |format|
      if @share_integral_record.update(share_integral_record_params)
        format.html { redirect_to @share_integral_record, notice: 'Share integral record was successfully updated.' }
        format.json { render :show, status: :ok, location: @share_integral_record }
      else
        format.html { render :edit }
        format.json { render json: @share_integral_record.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /share_integral_records/1
  # DELETE /share_integral_records/1.json
  def destroy
    @share_integral_record.destroy
    respond_to do |format|
      format.html { redirect_to share_integral_records_url, notice: 'Share integral record was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_share_integral_record
      @share_integral_record = ShareIntegralRecord.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def share_integral_record_params
      params.require(:share_integral_record).permit(:shared_customer_id, :register_customer_id, :is_confirm)
    end
end
