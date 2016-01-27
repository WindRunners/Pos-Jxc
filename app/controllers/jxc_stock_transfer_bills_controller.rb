class JxcStockTransferBillsController < ApplicationController
  before_action :set_jxc_stock_transfer_bill, only: [:show, :edit, :update, :destroy, :audit, :strike_a_balance, :invalid]
  before_action :set_bill_details, only:[:show, :edit]

  def index
    @jxc_stock_transfer_bills = JxcStockTransferBill.where(:bill_status.ne => '-1').order_by(:created_at => :desc).page(params[:page]).per(10)
  end

  def show
    @operation = 'show'
    #单据状态展示
    billStatus = @jxc_stock_transfer_bill.bill_status
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
    @jxc_stock_transfer_bill = JxcStockTransferBill.new
    @jxc_stock_transfer_bill.bill_no = @jxc_stock_transfer_bill.generate_bill_no
    @jxc_stock_transfer_bill.transfer_date = Time.now
    @jxc_stock_transfer_bill.handler << current_user
  end

  def edit
  end


  def create
    bill_info = params[:jxc_stock_transfer_bill]
    #调出仓库
    transfer_out_stock_id = bill_info[:transfer_out_stock_ids]
    #调入仓库
    transfer_in_stock_id = bill_info[:transfer_in_stock_ids]
    #经手人
    # handler_id = bill_info[:handler_id]

    @jxc_stock_transfer_bill = JxcStockTransferBill.new(jxc_stock_transfer_bill_params)
    @jxc_stock_transfer_bill.transfer_out_stock_ids << transfer_out_stock_id
    @jxc_stock_transfer_bill.transfer_in_stock_ids << transfer_in_stock_id
    #制单人
    @jxc_stock_transfer_bill.bill_maker << current_user
    #经手人信息
    @jxc_stock_transfer_bill.handler << current_user

    @jxc_stock_transfer_bill.transfer_date = stringParseDate(bill_info[:transfer_date])

    #单据商品明细
    billDetailArray = params[:billDetail]
    billDetailArray.each do |billDetailInfo|
      tempBillDetail = JxcTransferBillDetail.new

      #原成本价
      cost_price = billDetailInfo[:cost_price] == '' ? 0.00 : billDetailInfo[:cost_price]
      #调拨单价
      transfer_price = billDetailInfo[:transfer_price] == '' ? 0.00 : billDetailInfo[:transfer_price]
      #调拨数量
      count = billDetailInfo[:count] == '' ? 0 : billDetailInfo[:count]

      #调拨差额 (调拨单价 - 原成本价)
      transfer_amount = ((transfer_price.to_d - cost_price.to_d) * count.to_i).round(2)
      #小计 (调拨单价 × 调拨数量)
      amount = tempBillDetail.calculate_amount(transfer_price,count)

      tempBillDetail.cost_price = cost_price
      tempBillDetail.transfer_price = transfer_price
      tempBillDetail.count = count
      tempBillDetail.transfer_amount = transfer_amount
      tempBillDetail.amount = amount

      #商品信息
      tempBillDetail.resource_product_id = billDetailInfo[:product_id]
      tempBillDetail.unit = billDetailInfo[:unit]
      tempBillDetail.remark = billDetailInfo[:remark]

      tempBillDetail.stock_transfer_bill_id = @jxc_stock_transfer_bill.id

      tempBillDetail.transfer_out_stock_ids << transfer_out_stock_id
      tempBillDetail.transfer_in_stock_ids << transfer_in_stock_id

      tempBillDetail.save
    end

    respond_to do |format|
      if @jxc_stock_transfer_bill.save
        # format.html { redirect_to jxc_stock_transfer_bills_path, notice: '调拨单已经成功创建.' }
        format.js { render_js jxc_stock_transfer_bills_path, notice: '调拨单已经成功创建.' }
        format.json { render :show, status: :created, location: @jxc_stock_transfer_bill }
      else
        # format.html { render :new }
        format.js { render_js new_jxc_stock_transfer_bill_path }
        format.json { render json: @jxc_stock_transfer_bill.errors, status: :unprocessable_entity }
      end
    end
  end

  def update

    if @jxc_stock_transfer_bill.bill_status == '0'

      bill_info = params[:jxc_stock_transfer_bill]
      #调出仓库
      transfer_out_stock_id = bill_info[:transfer_out_stock_ids]
      #调入仓库
      transfer_in_stock_id = bill_info[:transfer_in_stock_ids]
      #经手人
      # handler_id = bill_info[:handler_id]

      @jxc_stock_transfer_bill.transfer_out_stock_ids[0] = transfer_out_stock_id
      @jxc_stock_transfer_bill.transfer_in_stock_ids[0] = transfer_in_stock_id
      #制单人
      @jxc_stock_transfer_bill.bill_maker << current_user
      #经手人信息
      @jxc_stock_transfer_bill.handler << current_user

      @jxc_stock_transfer_bill.customize_bill_no = bill_info[:customize_bill_no]
      @jxc_stock_transfer_bill.transfer_date = stringParseDate(bill_info[:transfer_date])
      @jxc_stock_transfer_bill.remark = bill_info[:remark]

      #删除单据商品详情
      JxcTransferBillDetail.where(stock_transfer_bill_id: @jxc_stock_transfer_bill.id).destroy

      #单据商品明细
      billDetailArray = params[:billDetail]
      billDetailArray.each do |billDetailInfo|
        tempBillDetail = JxcTransferBillDetail.new

        #原成本价
        cost_price = billDetailInfo[:cost_price] == '' ? 0.00 : billDetailInfo[:cost_price]
        #调拨单价
        transfer_price = billDetailInfo[:transfer_price] == '' ? 0.00 : billDetailInfo[:transfer_price]
        #调拨数量
        count = billDetailInfo[:count] == '' ? 0 : billDetailInfo[:count]

        #调拨差额 (调拨单价 - 原成本价)
        transfer_amount = ((transfer_price.to_d - cost_price.to_d) * count.to_i).round(2)
        #小计 (调拨单价 × 调拨数量)
        amount = tempBillDetail.calculate_amount(transfer_price,count)

        tempBillDetail.cost_price = cost_price
        tempBillDetail.transfer_price = transfer_price
        tempBillDetail.count = count
        tempBillDetail.transfer_amount = transfer_amount
        tempBillDetail.amount = amount

        #商品信息
        tempBillDetail.resource_product_id = billDetailInfo[:product_id]
        tempBillDetail.unit = billDetailInfo[:unit]
        tempBillDetail.remark = billDetailInfo[:remark]

        tempBillDetail.stock_transfer_bill_id = @jxc_stock_transfer_bill.id

        tempBillDetail.transfer_out_stock_ids << transfer_out_stock_id
        tempBillDetail.transfer_in_stock_ids << transfer_in_stock_id

        tempBillDetail.save
      end

      respond_to do |format|
        if @jxc_stock_transfer_bill.update
          # format.html { redirect_to @jxc_stock_transfer_bill, notice: '调拨单已经成功更新.' }
          format.js { render_js jxc_stock_transfer_bill_path(@jxc_stock_transfer_bill), notice: '调拨单已经成功更新.' }
          format.json { render :show, status: :ok, location: @jxc_stock_transfer_bill }
        else
          # format.html { render :edit }
          format.js { render_js edit_jxc_stock_transfer_bill_path(@jxc_stock_transfer_bill) }
          format.json { render json: @jxc_stock_transfer_bill.errors, status: :unprocessable_entity }
        end
      end

    else
      respond_to do |format|
        # format.html {redirect_to @jxc_stock_transfer_bill, notice: '单据当前状态无法更新!'}
        format.js { render_js edit_jxc_stock_transfer_bill_path(@jxc_stock_transfer_bill), notice: '单据当前状态无法更新!'}
      end
    end

  end

  def destroy
    @jxc_stock_transfer_bill.destroy
    respond_to do |format|
      # format.html { redirect_to jxc_stock_transfer_bills_url, notice: '调拨单已经成功删除.' }
      format.js { render_js jxc_stock_transfer_bills_url, notice: '调拨单已经成功删除.' }
      format.json { head :no_content }
    end
  end


  #审核
  def audit
    result = @jxc_stock_transfer_bill.audit(current_user)
    render json:result
  end



  #冲账
  def strike_a_balance
    result = @jxc_stock_transfer_bill.strike_a_balance(current_user)
    render json:result
  end



  #作废
  def invalid
    result = @jxc_stock_transfer_bill.bill_invalid
    render json:result
  end


  private
  # Use callbacks to share common setup or constraints between actions.
  def set_jxc_stock_transfer_bill
    @jxc_stock_transfer_bill = JxcStockTransferBill.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def jxc_stock_transfer_bill_params
    params.require(:jxc_stock_transfer_bill).permit(:bill_no, :customize_bill_no, :transfer_date, :remark, :transfer_way, :bill_status)
  end

  def set_bill_details
    @bill_details = JxcTransferBillDetail.where(:stock_transfer_bill_id => @jxc_stock_transfer_bill.id)
  end
end
