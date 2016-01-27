class JxcStockAssignBillsController < ApplicationController
  #要货单 controller

  before_action :set_jxc_stock_assign_bill, only: [:show, :edit, :update, :destroy, :audit, :strike_a_balance, :invalid]
  before_action :set_bill_details, only: [:show, :edit]

  def index
    @jxc_stock_assign_bills = JxcStockAssignBill.includes(:assign_in_stock).where(:bill_status.ne => '-1').order_by(:created_at => :desc).page(params[:page]).per(10)
  end

  def show
    @operation = 'show'
    #单据状态展示
    billStatus = @jxc_stock_assign_bill.bill_status
    @billStatus = ''
    case billStatus
      when '0'
        @billStatus = '已创建'
      when '1'
        @billStatus = '已审核'
      when '2'
        @billStatus = '已红冲'
      else
        @billStatus = '已作废'
    end
  end

  def new
    @jxc_stock_assign_bill = JxcStockAssignBill.new
    @jxc_stock_assign_bill.bill_no = @jxc_stock_assign_bill.generate_bill_no
    @jxc_stock_assign_bill.assign_date = Time.now
    @jxc_stock_assign_bill.handler << current_user
  end

  def edit
  end

  def create

    bill_info = params[:jxc_stock_assign_bill]
    #总库
    assign_out_stock_id = bill_info[:assign_out_stock_ids]
    #要货仓库
    assign_in_stock_id = bill_info[:assign_in_stock_ids]

    @jxc_stock_assign_bill = JxcStockAssignBill.new(jxc_stock_assign_bill_params)
    @jxc_stock_assign_bill.assign_out_stock_ids << assign_out_stock_id
    @jxc_stock_assign_bill.assign_in_stock_ids << assign_in_stock_id

    #制单人
    @jxc_stock_assign_bill.bill_maker << current_user
    #经手人
    @jxc_stock_assign_bill.handler << current_user

    @jxc_stock_assign_bill.assign_date = stringParseDate(bill_info[:assign_date])

    #单据商品明细
    billDetailArray = params[:billDetail]
    billDetailArray.each do |billDetailInfo|
      tempBillDetail = JxcTransferBillDetail.new

      #装箱规格
      pack_spec = billDetailInfo[:pack_spec] == '' ? 0 : billDetailInfo[:pack_spec]
      #箱数
      package_count = billDetailInfo[:package_count] == '' ? 0 : billDetailInfo[:package_count]
      #数量
      count = billDetailInfo[:count] == '' ? 0 : billDetailInfo[:count]

      #装箱规格
      tempBillDetail.pack_spec = pack_spec
      #箱数
      tempBillDetail.package_count = package_count
      #基本数量
      tempBillDetail.count = count

      #商品信息
      tempBillDetail.resource_product_id = billDetailInfo[:product_id]
      tempBillDetail.unit = billDetailInfo[:unit]
      tempBillDetail.remark = billDetailInfo[:remark]

      tempBillDetail.stock_assign_bill_id = @jxc_stock_assign_bill.id

      tempBillDetail.assign_out_stock_ids << assign_out_stock_id
      tempBillDetail.assign_in_stock_ids << assign_in_stock_id

      tempBillDetail.save
    end

    respond_to do |format|
      if @jxc_stock_assign_bill.save
        # format.html { redirect_to @jxc_stock_assign_bill, notice: '要货单创建成功.' }
        format.js { render_js jxc_stock_assign_bill_path(@jxc_stock_assign_bill), notice: '要货单创建成功.' }
        format.json { render :show, status: :created, location: @jxc_stock_assign_bill }
      else
        # format.html { render :new }
        format.js { render_js new_jxc_stock_assign_bill_path }
        format.json { render json: @jxc_stock_assign_bill.errors, status: :unprocessable_entity }
      end
    end
  end

  def update

    if @jxc_stock_assign_bill.bill_status == '0'

      bill_info = params[:jxc_stock_assign_bill]
      #总库
      assign_out_stock_id = bill_info[:assign_out_stock_ids]
      #要货仓库
      assign_in_stock_id = bill_info[:assign_in_stock_ids]

      @jxc_stock_assign_bill.assign_out_stock_ids[0] = assign_out_stock_id
      @jxc_stock_assign_bill.assign_in_stock_ids[0] = assign_in_stock_id
      #制单人
      @jxc_stock_assign_bill.bill_maker << current_user
      #经手人
      @jxc_stock_assign_bill.handler << current_user

      @jxc_stock_assign_bill.customize_bill_no = bill_info[:customize_bill_no]
      @jxc_stock_assign_bill.assign_date = stringParseDate(bill_info[:assign_date])
      @jxc_stock_assign_bill.remark = bill_info[:remark]

      #删除单据商品详情
      JxcTransferBillDetail.where(stock_assign_bill_id: @jxc_stock_assign_bill.id).destroy

      #单据商品明细
      billDetailArray = params[:billDetail]
      billDetailArray.each do |billDetailInfo|
        tempBillDetail = JxcTransferBillDetail.new

        #装箱规格
        pack_spec = billDetailInfo[:pack_spec] == '' ? 0 : billDetailInfo[:pack_spec]
        #箱数
        package_count = billDetailInfo[:package_count] == '' ? 0 : billDetailInfo[:package_count]
        #数量
        count = billDetailInfo[:count] == '' ? 0 : billDetailInfo[:count]

        #装箱规格
        tempBillDetail.pack_spec = pack_spec
        #箱数
        tempBillDetail.package_count = package_count
        #基本数量
        tempBillDetail.count = count

        #商品信息
        tempBillDetail.resource_product_id = billDetailInfo[:product_id]
        tempBillDetail.unit = billDetailInfo[:unit]
        tempBillDetail.remark = billDetailInfo[:remark]

        tempBillDetail.stock_assign_bill_id = @jxc_stock_assign_bill.id

        tempBillDetail.assign_out_stock_ids << assign_out_stock_id
        tempBillDetail.assign_in_stock_ids << assign_in_stock_id

        tempBillDetail.save
      end

      respond_to do |format|
        if @jxc_stock_assign_bill.update
          # format.html { redirect_to @jxc_stock_assign_bill, notice: '要货单更新成功.' }
          format.js { render_js jxc_stock_assign_bill_path(@jxc_stock_assign_bill), notice: '要货单更新成功.' }
          format.json { render :show, status: :ok, location: @jxc_stock_assign_bill }
        else
          # format.html { render :edit }
          format.js { render_js edit_jxc_stock_assign_bill_path }
          format.json { render json: @jxc_stock_assign_bill.errors, status: :unprocessable_entity }
        end
      end

    else
      respond_to do |format|
        # format.html {redirect_to @jxc_stock_assign_bill, notice: '单据当前状态无法更新!'}
        format.js { render_js jxc_stock_assign_bill_path(@jxc_stock_assign_bill), notice: '单据当前状态无法更新!'}
      end
    end
  end

  def destroy
    @jxc_stock_assign_bill.destroy
    respond_to do |format|
      # format.html { redirect_to jxc_stock_assign_bills_url, notice: '要货单删除成功.' }
      format.js { render_js jxc_stock_assign_bills_url, notice: '要货单删除成功.' }
      format.json { head :no_content }
    end
  end

  #审核
  def audit
    result = @jxc_stock_assign_bill.audit
    render json:result
  end

  #红冲
  def strike_a_balance
    result = @jxc_stock_assign_bill.strike_a_balance
    render json:result
  end

  #作废
  def invalid
    result = @jxc_stock_assign_bill.bill_invalid
    render json:result
  end

  private
  def set_jxc_stock_assign_bill
    @jxc_stock_assign_bill = JxcStockAssignBill.find(params[:id])
  end

  def jxc_stock_assign_bill_params
    params.require(:jxc_stock_assign_bill).permit(:bill_no, :customize_bill_no, :assign_date, :remark, :bill_status)
  end

  def set_bill_details
    @bill_details = JxcTransferBillDetail.where(:stock_assign_bill_id => @jxc_stock_assign_bill.id)
  end
end
