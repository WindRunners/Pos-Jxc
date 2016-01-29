class JxcCostAdjustBillsController < ApplicationController
  before_action :set_jxc_cost_adjust_bill, only: [:show, :edit, :update, :destroy, :audit, :strike_a_balance, :invalid]
  before_action :set_bill_details, only: [:show, :edit]

  def index
    @jxc_cost_adjust_bills = JxcCostAdjustBill.includes(:jxc_storage,:handler).where(:bill_status.ne => '-1').order_by(:created_at => :desc).page(params[:page]).per(10)
  end

  def show
    @operation = 'show'
    #单据状态展示
    billStatus = @jxc_cost_adjust_bill.bill_status
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
    @jxc_cost_adjust_bill = JxcCostAdjustBill.new
    @jxc_cost_adjust_bill.bill_no = @jxc_cost_adjust_bill.generate_bill_no
    @jxc_cost_adjust_bill.adjust_date = Time.now
    @jxc_cost_adjust_bill.handler << current_user
  end

  def edit
  end

  def create
    bill_info = params[:jxc_cost_adjust_bill]
    #仓库
    storage_id = bill_info[:storage_id]
    #经手人
    # handler_id = bill_info[:handler_id]

    @jxc_cost_adjust_bill = JxcCostAdjustBill.new(jxc_cost_adjust_bill_params)
    @jxc_cost_adjust_bill.adjust_date = stringParseDate(bill_info[:adjust_date])
    @jxc_cost_adjust_bill.storage_id = storage_id
    #经手人信息
    @jxc_cost_adjust_bill.handler << current_user
    #制单人
    @jxc_cost_adjust_bill.bill_maker << current_user

    #单据明细
    billDetailArray = params[:billDetail]
    billDetailArray.each do |billDetailInfo|
      tempBillDetail = JxcBillDetail.new

      #调前成本单价
      origin_price = billDetailInfo[:origin_price] == '' ? 0.00 : billDetailInfo[:origin_price]
      #调后单价
      adjusted_price = billDetailInfo[:adjusted_price] == '' ? 0.00 : billDetailInfo[:adjusted_price]

      #库存数量
      inventory_count = billDetailInfo[:inventory_count] == '' ? 0 : billDetailInfo[:inventory_count]
      #调整金额
      amount = ((adjusted_price.to_d - origin_price.to_d) * inventory_count.to_i).round(2)

      tempBillDetail[:origin_price] = origin_price
      tempBillDetail[:adjusted_price] = adjusted_price
      tempBillDetail[:inventory_count] = inventory_count
      tempBillDetail[:amount] = amount

      #商品ID
      tempBillDetail.resource_product_id = billDetailInfo[:product_id]
      #商品计量单位
      tempBillDetail.unit = billDetailInfo[:unit]
      #备注
      tempBillDetail.remark = billDetailInfo[:remark]

      #商品明细 所属单据
      tempBillDetail.cost_adjust_bill_id = @jxc_cost_adjust_bill._id
      #商品 调整仓库
      tempBillDetail.storage_id = storage_id

      tempBillDetail.save
    end


    respond_to do |format|
      if @jxc_cost_adjust_bill.save
        # format.html { redirect_to jxc_cost_adjust_bills_path, notice: '成本调整单创建成功.' }
        format.js { render_js jxc_cost_adjust_bills_path, notice: '成本调整单创建成功.' }
        format.json { render :show, status: :created, location: @jxc_cost_adjust_bill }
      else
        # format.html { render :new }
        format.js { render_js new_jxc_cost_adjust_bill_path }
        format.json { render json: @jxc_cost_adjust_bill.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @jxc_cost_adjust_bill.bill_status == '0'

      bill_info = params[:jxc_cost_adjust_bill]
      #仓库
      storage_id = bill_info[:storage_id]
      #经手人
      # handler_id = bill_info[:handler_id]

      @jxc_cost_adjust_bill.storage_id = storage_id
      #经手人信息
      @jxc_cost_adjust_bill.handler << current_user
      #制单人
      @jxc_cost_adjust_bill.bill_maker << current_user

      @jxc_cost_adjust_bill.customize_bill_no = bill_info[:customize_bill_no]
      @jxc_cost_adjust_bill.adjust_date = stringParseDate(bill_info[:adjust_date])
      @jxc_cost_adjust_bill.remark = bill_info[:remark]

      #先删除单据以前的商品详情
      JxcBillDetail.where(cost_adjust_bill_id: @jxc_cost_adjust_bill.id).destroy

      #单据明细
      billDetailArray = params[:billDetail]
      billDetailArray.each do |billDetailInfo|
        tempBillDetail = JxcBillDetail.new

        #调前成本单价
        origin_price = billDetailInfo[:origin_price] == '' ? 0.00 : billDetailInfo[:origin_price]
        #调后单价
        adjusted_price = billDetailInfo[:adjusted_price] == '' ? 0.00 : billDetailInfo[:adjusted_price]

        #库存数量
        inventory_count = billDetailInfo[:inventory_count] == '' ? 0 : billDetailInfo[:inventory_count]
        #调整金额
        amount = ((adjusted_price.to_d - origin_price.to_d) * inventory_count.to_i).round(2)

        tempBillDetail[:origin_price] = origin_price
        tempBillDetail[:adjusted_price] = adjusted_price
        tempBillDetail[:inventory_count] = inventory_count
        tempBillDetail[:amount] = amount

        #商品ID
        tempBillDetail.resource_product_id = billDetailInfo[:product_id]
        #商品计量单位
        tempBillDetail.unit = billDetailInfo[:unit]
        #备注
        tempBillDetail.remark = billDetailInfo[:remark]

        #商品明细 所属单据
        tempBillDetail.cost_adjust_bill_id = @jxc_cost_adjust_bill._id
        #商品 调整仓库
        tempBillDetail.storage_id = storage_id

        tempBillDetail.save
      end

      respond_to do |format|
        if @jxc_cost_adjust_bill.update
          # format.html { redirect_to @jxc_cost_adjust_bill, notice: '成本调整单更新成功.' }
          format.js { render_js jxc_cost_adjust_bill_path(@jxc_cost_adjust_bill), notice: '成本调整单更新成功.' }
          format.json { render :show, status: :ok, location: @jxc_cost_adjust_bill }
        else
          # format.html { render :edit }
          format.js { render_js edit_jxc_cost_adjust_bill_path(@jxc_cost_adjust_bill) }
          format.json { render json: @jxc_cost_adjust_bill.errors, status: :unprocessable_entity }
        end
      end

    else

      respond_to do |format|
        # format.html { redirect_to @jxc_cost_adjust_bill, notice: '单据当前状态无法更新!'}
        format.js { render_js edit_jxc_cost_adjust_bill_path(@jxc_cost_adjust_bill), notice: '单据当前状态无法更新!'}
      end

    end

  end

  def destroy
    @jxc_cost_adjust_bill.destroy
    respond_to do |format|
      # format.html { redirect_to jxc_cost_adjust_bills_url, notice: '成本调整单删除成功.' }
      format.js { render_js jxc_cost_adjust_bills_url, notice: '成本调整单删除成功.' }
      format.json { head :no_content }
    end
  end


  #审核
  def audit
    result = @jxc_cost_adjust_bill.audit(current_user)
    render json:result
  end

  #冲账
  def strike_a_balance
    result = @jxc_cost_adjust_bill.strike_a_balance(current_user)
    render json:result
  end

  #作废
  def invalid
    result = @jxc_cost_adjust_bill.bill_invalid
    render json:result
  end



  private
  # Use callbacks to share common setup or constraints between actions.
  def set_jxc_cost_adjust_bill
    @jxc_cost_adjust_bill = JxcCostAdjustBill.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def jxc_cost_adjust_bill_params
    params.require(:jxc_cost_adjust_bill).permit(:bill_no, :customize_bill_no, :adjust_date, :remark, :bill_status)
  end

  def set_bill_details
    @bill_details = JxcBillDetail.where(:cost_adjust_bill_id => @jxc_cost_adjust_bill.id)
  end
end
