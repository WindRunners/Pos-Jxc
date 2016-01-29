class TraceabilitiesController < ApplicationController
  before_action :set_traceability, only: [:show, :edit, :update, :destroy]

  # GET /traceabilities
  # GET /traceabilities.json
  def index
    if params[:code].present?
      @jsonresult=[]
      begin
        @traceabilitie=Traceability.find_by(:barcode => params[:code])
      rescue
        @traceabilitie=nil
      end

      if @traceabilitie.present?


        if @traceabilitie.childs.present?
          # tr=@traceabilitie.childs[0]
          # @traceabilitie.childs.each do |tr|
          #   @jsonresult << {:product => tr.jxc_transfer_bill_detail.product,
          #                   :stock_in_date => tr.jxc_transfer_bill_detail.jxc_stock_assign_bill.created_at.strftime("%Y-%m-%d %H:%M:%S"),
          #                   :storage => tr.jxc_transfer_bill_detail.jxc_stock_assign_bill.assign_in_stock.to_s
          #   }
          # end
          @jsonresult<<{:product => @traceabilitie.jxc_bill_detail.product,
                        :stock_in_date => @traceabilitie.jxc_bill_detail.jxc_purchase_stock_in_bill.stock_in_date.strftime("%Y-%m-%d %H:%M:%S"),
                        :stock_in_storage => @traceabilitie.jxc_storage.to_s,
                        :provider => @traceabilitie.jxc_bill_detail.jxc_contacts_unit.to_s,
                        :assign_in_storage => "",
          }
        end
        if @traceabilitie.parent.present?
          @jsonresult << {:product => @traceabilitie.jxc_transfer_bill_detail.product,
                          :stock_in_date => @traceabilitie.jxc_transfer_bill_detail.jxc_stock_assign_bill.assign_date.strftime("%Y-%m-%d %H:%M:%S"),
                          :stock_in_storage => @traceabilitie.parent.jxc_storage.to_s,
                          :assign_in_storage => @traceabilitie.jxc_storage.to_s,
                          :provider=>""
          }
          @jsonresult<<{:product => @traceabilitie.parent.jxc_bill_detail.product,
                        :stock_in_date => @traceabilitie.parent.jxc_bill_detail.jxc_purchase_stock_in_bill.stock_in_date.strftime("%Y-%m-%d %H:%M:%S"),
                        :stock_in_storage => @traceabilitie.parent.jxc_storage.to_s,
                        :provider => @traceabilitie.parent.jxc_bill_detail.jxc_contacts_unit.to_s,
                        :assign_in_storage =>""
          }
        end

      end
      respond_to do |format|
        format.js
      end
    end
  end

  # GET /traceabilities/1
  # GET /traceabilities/1.json
  def show
  end

  # GET /traceabilities/new
  def new
    @traceability = Traceability.new
  end

  # GET /traceabilities/1/edit
  def edit
  end

  def origincode
    # @traceabilities = Traceability.all
    @traceabilities=Traceability.where(:flag => 0, :jxc_bill_detail_id => {'$ne' => nil}, :codetype => 0).distinct(:jxc_bill_detail_id)
    p @traceabilities
    @jxc_bill_details=JxcBillDetail.in(:id => @traceabilities).page params[:page]
    # @jxc_bill_details
  end

  def subcode
    @traceabilities=nil
    if params[:code].present?
      begin
        @parent=Traceability.find_by(:barcode => params[:code])

        p "-=-=-=-=-=-=-=-=-=-=-=-=-=-=#{@parent.to_json}"
        # @parent.includes(:product)
        @traceabilities=@parent.childs.includes(:product)

        p "-=-=-=-=-=-=-=-=-=-=-=-=-=-=#{@traceabilities.to_json}"
        @jsonresult=[]
        @traceabilities.includes(:product).each do |tr|
          @jsonresult << {:id => tr.id, :barcode => tr.barcode, :product => tr.product}
        end

        # p "-=-=-=-=-=-=-=-=-=-=-#{@jsonresult.to_s}"
        respond_to do |format|
          format.js
        end
      rescue
      end
    end
    # p "@traceabilities=@parent.childs#{@parent.childs}"

  end

  def print
    if params[:bill][:id].length > 0
      @traceabilities=Traceability.in(:jxc_bill_detail_id => params[:bill][:id]).where(:flag => 0, :codetype => 0)
      @traceabilities.update_all(:printdate => Time.now.localtime)
      render 'printorigin.json.jbuilder'
    end
  end

  def

    # POST /traceabilities
    # POST /traceabilities.json
  def create
    @traceability = Traceability.new(traceability_params)

    respond_to do |format|
      if @traceability.save
        format.html { redirect_to @traceability, notice: 'Traceability was successfully created.' }
        format.json { render :show, status: :created, location: @traceability }
      else
        format.html { render :new }
        format.json { render json: @traceability.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /traceabilities/1
  # PATCH/PUT /traceabilities/1.json
  def update
    respond_to do |format|
      if @traceability.update(traceability_params)
        format.html { redirect_to @traceability, notice: 'Traceability was successfully updated.' }
        format.json { render :show, status: :ok, location: @traceability }
      else
        format.html { render :edit }
        format.json { render json: @traceability.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /traceabilities/1
  # DELETE /traceabilities/1.json
  def destroy
    @traceability.destroy
    respond_to do |format|
      format.html { redirect_to traceabilities_url, notice: 'Traceability was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_traceability
    @traceability = Traceability.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def traceability_params
    params.require(:traceability).permit(:barcode, :codetype, :printdate, :jxc_bill_detail_id, :jxc_transfer_bill_detail_id)
  end
end
