class JxcOtherStockOutBillsController < ApplicationController
  before_action :set_jxc_other_stock_out_bill, only: [:show, :edit, :update, :destroy, :audit, :strike_a_balance, :invalid]
  before_action :set_bill_details, only:[:show, :edit]
  before_action :set_stock_out_types, only:[:new, :show, :edit]

  def index
    @jxc_other_stock_out_bills = JxcOtherStockOutBill.where(:bill_status.ne => '-1').order_by(:created_at => :desc).page(params[:page]).per(10)
  end

  def show
    @operation = 'show'
    #单据状态展示
    billStatus = @jxc_other_stock_out_bill.bill_status
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
    @jxc_other_stock_out_bill = JxcOtherStockOutBill.new
    @jxc_other_stock_out_bill.bill_no = @jxc_other_stock_out_bill.generate_bill_no
    @jxc_other_stock_out_bill.stock_out_date = Time.now
    @jxc_other_stock_out_bill.handler = current_user.staff
  end

  def edit
  end

  def create
    bill_info = params[:jxc_other_stock_out_bill]
    consumer_id = bill_info[:consumer_id]   #客户ID
    storage_id = bill_info[:storage_id]    #入货仓库ID
    handler_id = bill_info[:handler_id]   #经手人ID

    @jxc_other_stock_out_bill = JxcOtherStockOutBill.new(jxc_other_stock_out_bill_params)
    @jxc_other_stock_out_bill.stock_out_date = stringParseDate(bill_info[:stock_out_date])
    @jxc_other_stock_out_bill.consumer_id = consumer_id
    @jxc_other_stock_out_bill.storage_id = storage_id
    @jxc_other_stock_out_bill.handler_id = handler_id
    #制单人
    @jxc_other_stock_out_bill.bill_maker = current_user

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

      tempBillDetail.product_id = billDetailInfo[:product_id]   #商品ID
      tempBillDetail.unit = billDetailInfo[:unit]       #商品计量单位
      tempBillDetail.remark = billDetailInfo[:remark]   #备注


      tempBillDetail.unit_id = consumer_id    #客户  <商品去向>
      tempBillDetail.other_out_bill_id = @jxc_other_stock_out_bill._id  #商品 所属订单 <单据>
      tempBillDetail.storage_id = storage_id  #商品 出库仓库 <商品来源>

      tempBillDetail.save
    end

    respond_to do |format|
      if @jxc_other_stock_out_bill.save
        format.html { redirect_to @jxc_other_stock_out_bill, notice: '其他出库单已经成功创建.' }
        format.json { render :show, status: :created, location: @jxc_other_stock_out_bill }
      else
        format.html { render :new }
        format.json { render json: @jxc_other_stock_out_bill.errors, status: :unprocessable_entity }
      end
    end
  end

  def update

    if @jxc_other_stock_out_bill.bill_status == '0'
      bill_info = params[:jxc_other_stock_out_bill]
      consumer_id = bill_info[:consumer_id]   #客户ID
      storage_id = bill_info[:storage_id]    #入货仓库ID
      handler_id = bill_info[:handler_id]   #经手人ID

      @jxc_other_stock_out_bill.consumer_id = consumer_id
      @jxc_other_stock_out_bill.storage_id = storage_id
      @jxc_other_stock_out_bill.handler_id = handler_id
      #制单人
      @jxc_other_stock_out_bill.bill_maker = current_user

      @jxc_other_stock_out_bill.customize_bill_no = bill_info[:customize_bill_no]
      @jxc_other_stock_out_bill.stock_out_type = bill_info[:stock_out_type]
      @jxc_other_stock_out_bill.stock_out_date = stringParseDate(bill_info[:stock_out_date])
      @jxc_other_stock_out_bill.remark = bill_info[:remark]

      #先删除单据以前的商品详情
      JxcBillDetail.where(other_out_bill_id: @jxc_other_stock_out_bill.id).destroy

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

        tempBillDetail.product_id = billDetailInfo[:product_id]   #商品ID
        tempBillDetail.unit = billDetailInfo[:unit]       #商品计量单位
        tempBillDetail.remark = billDetailInfo[:remark]   #备注


        tempBillDetail.unit_id = consumer_id    #客户  <商品去向>
        tempBillDetail.other_out_bill_id = @jxc_other_stock_out_bill._id  #商品 所属订单 <单据>
        tempBillDetail.storage_id = storage_id  #商品 出库仓库 <商品来源>

        tempBillDetail.save
      end

      respond_to do |format|
        if @jxc_other_stock_out_bill.update
          format.html { redirect_to jxc_other_stock_out_bills_path, notice: '其他出库单已经成功更新.' }
          format.json { render :show, status: :ok, location: @jxc_other_stock_out_bill }
        else
          format.html { render :edit }
          format.json { render json: @jxc_other_stock_out_bill.errors, status: :unprocessable_entity }
        end
      end

    else
      respond_to do |format|
        format.html {redirect_to @jxc_other_stock_out_bill, notice: '销售出库单当前状态无法更新。'}
      end
    end

  end

  def destroy
    @jxc_other_stock_out_bill.destroy
    respond_to do |format|
      format.html { redirect_to jxc_other_stock_out_bills_url, notice: '其他出库单已经成功删除.' }
      format.json { head :no_content }
    end
  end

  #审核
  def audit
    result = @jxc_other_stock_out_bill.audit(current_user)
    render json:result
  end


  #冲账
  def strike_a_balance
    result = @jxc_other_stock_out_bill.strike_a_balance(current_user)
    render json:result
  end


  #作废
  def invalid
    result = @jxc_other_stock_out_bill.bill_invalid
    render json:result
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_jxc_other_stock_out_bill
    @jxc_other_stock_out_bill = JxcOtherStockOutBill.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def jxc_other_stock_out_bill_params
    params.require(:jxc_other_stock_out_bill).permit(:bill_no, :customize_bill_no, :stock_out_date, :stock_out_type, :remark, :bill_status)
  end

  def set_bill_details
    @bill_details = JxcBillDetail.includes(:product).where(:other_out_bill_id => @jxc_other_stock_out_bill.id)
  end

  def set_stock_out_types
    @stock_out_types = JxcDictionary.where(:dic_desc => 'stock_out_type')
  end
end
