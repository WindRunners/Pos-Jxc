class JxcStockReduceBillsController < ApplicationController
  before_action :set_jxc_stock_reduce_bill, only: [:show, :edit, :update, :destroy, :audit, :strike_a_balance, :invalid]
  before_action :set_bill_details, only: [:show, :edit]

  def index
    @jxc_stock_reduce_bills = JxcStockReduceBill.where(:bill_status.ne => '-1').order_by(:created_at => :desc).page(params[:page]).per(10)
  end

  def show
    @operation = 'show'
    #单据状态展示
    billStatus = @jxc_stock_reduce_bill.bill_status
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
    @jxc_stock_reduce_bill = JxcStockReduceBill.new
    @jxc_stock_reduce_bill.bill_no = @jxc_stock_reduce_bill.generate_bill_no
    @jxc_stock_reduce_bill.reduce_date = Time.now
    @jxc_stock_reduce_bill.handler = current_user.staff
  end

  def edit
  end

  def create
    bill_info = params[:jxc_stock_reduce_bill]
    #仓库
    storage_id = bill_info[:storage_id]
    #经手人
    handler_id = bill_info[:handler_id]

    @jxc_stock_reduce_bill = JxcStockReduceBill.new(jxc_stock_reduce_bill_params)
    @jxc_stock_reduce_bill.storage_id = storage_id
    @jxc_stock_reduce_bill.handler_id = handler_id
    #制单人
    @jxc_stock_reduce_bill.bill_maker = current_user

    @jxc_stock_reduce_bill.reduce_date = stringParseDate(bill_info[:reduce_date])

    #单据商品明细
    billDetailArray = params[:billDetail]
    billDetailArray.each do |billDetailInfo|
      tempBillDetail = JxcBillDetail.new

      #商品单价
      price = billDetailInfo[:price] == '' ? 0.00 : billDetailInfo[:price]
      #数量
      count = billDetailInfo[:count] == '' ? 0 : billDetailInfo[:count]
      #金额
      amount = tempBillDetail.calculate_amount(price,count)

      tempBillDetail.price = price
      tempBillDetail.count = count
      tempBillDetail.amount = amount

      #商品ID
      tempBillDetail.product_id = billDetailInfo[:product_id]
      #商品计量单位
      tempBillDetail.unit = billDetailInfo[:unit]
      #备注
      tempBillDetail.remark = billDetailInfo[:remark]

      #商品明细 所属单据
      tempBillDetail.stock_reduce_bill_id = @jxc_stock_reduce_bill._id
      #商品 入库仓库
      tempBillDetail.storage_id = storage_id

      tempBillDetail.save
    end

    respond_to do |format|
      if @jxc_stock_reduce_bill.save
        format.html { redirect_to jxc_stock_reduce_bills_path, notice: '报损单已经成功创建.' }
        format.json { render :show, status: :created, location: @jxc_stock_reduce_bill }
      else
        format.html { render :new }
        format.json { render json: @jxc_stock_reduce_bill.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @jxc_stock_reduce_bill.bill_status == '0'

      bill_info = params[:jxc_stock_reduce_bill]
      #仓库
      storage_id = bill_info[:storage_id]
      #经手人
      handler_id = bill_info[:handler_id]

      @jxc_stock_reduce_bill.storage_id = storage_id
      @jxc_stock_reduce_bill.handler_id = handler_id
      #制单人
      @jxc_stock_reduce_bill.bill_maker = current_user

      @jxc_stock_reduce_bill.customize_bill_no = bill_info[:customize_bill_no]
      @jxc_stock_reduce_bill.reduce_date = stringParseDate(bill_info[:reduce_date])
      @jxc_stock_reduce_bill.remark = bill_info[:remark]

      #先删除单据以前的商品详情
      JxcBillDetail.where(stock_reduce_bill_id: @jxc_stock_reduce_bill.id).destroy

      #单据商品明细
      billDetailArray = params[:billDetail]
      billDetailArray.each do |billDetailInfo|
        tempBillDetail = JxcBillDetail.new

        #商品单价
        price = billDetailInfo[:price] == '' ? 0.00 : billDetailInfo[:price]
        #数量
        count = billDetailInfo[:count] == '' ? 0 : billDetailInfo[:count]
        #金额
        amount = tempBillDetail.calculate_amount(price,count)

        tempBillDetail.price = price
        tempBillDetail.count = count
        tempBillDetail.amount = amount

        #商品ID
        tempBillDetail.product_id = billDetailInfo[:product_id]
        #商品计量单位
        tempBillDetail.unit = billDetailInfo[:unit]
        #备注
        tempBillDetail.remark = billDetailInfo[:remark]

        #商品明细 所属单据
        tempBillDetail.stock_reduce_bill_id = @jxc_stock_reduce_bill._id
        #商品 入库仓库
        tempBillDetail.storage_id = storage_id

        tempBillDetail.save
      end

      respond_to do |format|
        if @jxc_stock_reduce_bill.update
          format.html { redirect_to @jxc_stock_reduce_bill, notice: '报损单已经成功更新.' }
          format.json { render :show, status: :ok, location: @jxc_stock_reduce_bill }
        else
          format.html { render :edit }
          format.json { render json: @jxc_stock_reduce_bill.errors, status: :unprocessable_entity }
        end
      end

    else

      respond_to do |format|
        format.html { redirect_to @jxc_stock_reduce_bill, notice: '报损单当前状态无法修改!'}
      end

    end
  end

  def destroy
    @jxc_stock_reduce_bill.destroy
    respond_to do |format|
      format.html { redirect_to jxc_stock_reduce_bills_url, notice: '报损单已经成功删除.' }
      format.json { head :no_content }
    end
  end


  #审核
  def audit
    result = @jxc_stock_reduce_bill.audit(current_user)
    render json:result
  end


  #冲账
  def strike_a_balance
    result = @jxc_stock_reduce_bill.strike_a_balance(current_user)
    render json:result
  end


  #作废
  def invalid
    result = @jxc_stock_reduce_bill.bill_invalid
    render json:result
  end


  private
  # Use callbacks to share common setup or constraints between actions.
  def set_jxc_stock_reduce_bill
    @jxc_stock_reduce_bill = JxcStockReduceBill.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def jxc_stock_reduce_bill_params
    params.require(:jxc_stock_reduce_bill).permit(:bill_no, :customize_bill_no, :reduce_date, :remark, :bill_status)
  end

  def set_bill_details
    @bill_details = JxcBillDetail.includes(:product).where(:stock_reduce_bill_id => @jxc_stock_reduce_bill.id)
  end
end
