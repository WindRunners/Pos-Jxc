class ShareIntegralsController < ApplicationController
  before_action :set_share_integral, only: [:show, :edit, :update, :destroy]
  skip_before_action :authenticate_user!, only: [:register, :share_time_check, :share]

  # GET /share_integrals
  # GET /share_integrals.json
  def index
    @share_integrals = ShareIntegral.all
  end

  # GET /share_integrals/1
  # GET /share_integrals/1.json
  def show
  end

  # GET /share_integrals/new
  def new
    @share_integral = ShareIntegral.new
  end

  # GET /share_integrals/1/edit
  def edit
  end

  # POST /share_integrals
  # POST /share_integrals.json
  def create
    @share_integral = ShareIntegral.new(share_integral_params)
    respond_to do |format|
      if @share_integral.save
        format.js { render_js share_integrals_path, 'Share integral was successfully created.' }
        # format.html { redirect_to @share_integral, notice: 'Share integral was successfully created.' }
        format.json { render :show, status: :created, location: @share_integral }
      else
        format.html { render :new }
        format.json { render json: @share_integral.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /share_integrals/1
  # PATCH/PUT /share_integrals/1.json
  def update
    respond_to do |format|
      if @share_integral.update(share_integral_params)
        format.js { render_js share_integrals_path, 'Share integral was successfully updated.' }
        # format.html { redirect_to @share_integral, notice: 'Share integral was successfully updated.' }
        format.json { render :show, status: :ok, location: @share_integral }
      else
        format.html { render :edit }
        format.json { render json: @share_integral.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /share_integrals/1
  # DELETE /share_integrals/1.json
  def destroy
    @share_integral.destroy
    respond_to do |format|
      format.js { render_js share_integrals_path, 'Share integral was successfully destroyed.' }
      format.html { redirect_to share_integrals_url, notice: 'Share integral was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def register
    data = {}
    @share_integral = ShareIntegral.find(params[:share_integral_id])
    customer = Customer.find_by_mobile(params[:mobile])
    if customer.present?
      data['flag'] = 0
      data['message'] = '该用户已注册！'
    else
      customer = Customer.new(:mobile => params[:mobile])
      if customer.save
        share_integral_record = @share_integral.share_integral_records.build();
        share_integral_record['shared_customer_id'] = params[:shared_customer_id]
        share_integral_record['register_customer_id'] = customer.id
        share_integral_record['is_confirm'] = 0
        share_integral_record.save
        data['flag'] = 1
        data['message'] = '注册成功！'

      else
        data['flag'] = -1
        data['message'] = '注册失败！'
      end
    end
    respond_to do |format|
      format.json { render json: data }
    end
  end


  def share_time_check

    start_date = params[:share_integral]['start_date']
    end_date = params[:share_integral]['end_date']
    rows = ShareIntegral.where({"$or" => [{:start_date => {"$gte" => start_date}, :end_date => {"$lte" => end_date}},
                                          {:start_date => {"$lte" => start_date}, :end_date => {"$gte" => end_date}},
                                          {:start_date => {"$lte" => start_date}, :end_date => {"$lte" => end_date}},
                                          {:start_date => {"$gte" => start_date}, :end_date => {"$gte" => end_date}}]}).count
    data ={}
    if rows > 0
      data['flag'] = 0
      data['message'] = '活动时间冲突！'
    else
      data['flag'] = 1
      data['message'] = '活动时间正常'
    end
    respond_to do |format|
      format.json { render json: data }
    end
  end


  def share
    @share_integral = ShareIntegral.find(params[:share_integral_id])
    render :layout => nil
  end


  private
  # Use callbacks to share common setup or constraints between actions.
  def set_share_integral
    @share_integral = ShareIntegral.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def share_integral_params
    params.require(:share_integral).permit(:title, :start_date, :end_date, :shared_give_integral, :register_give_integral, :logo, :share_app_pic, :share_out_pic, :status, :desc)
  end
end
