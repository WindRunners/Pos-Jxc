class JxcOtherStockInBillsController < ApplicationController
  before_action :set_jxc_other_stock_in_bill, only: [:show, :edit, :update, :destroy, :audit, :strike_a_balance, :invalid]
  before_action :set_bill_details, only:[:show, :edit]
  before_action :set_stock_in_types, only:[:show, :new, :edit]

  def index
    @jxc_other_stock_in_bills = JxcOtherStockInBill.where(:bill_status.ne => '-1').order_by(:created_at => :desc).page(params[:page]).per(10)
  end

  def show
    @operation = 'show'
    #单据状态展示
    billStatus = @jxc_other_stock_in_bill.bill_status
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
    @jxc_other_stock_in_bill = JxcOtherStockInBill.new
    @jxc_other_stock_in_bill.bill_no = @jxc_other_stock_in_bill.generate_bill_no
    @jxc_other_stock_in_bill.stock_in_date = Time.now
    @jxc_other_stock_in_bill.handler << current_user
  end

  def edit
  end

  def create
    bill_info = params[:jxc_other_stock_in_bill]
    #供应商
    supplier_id = bill_info[:supplier_id]
    #仓库
    storage_id = bill_info[:storage_id]
    #经手人
    # handler_id = bill_info[:handler_id]

    @jxc_other_stock_in_bill = JxcOtherStockInBill.new(jxc_other_stock_in_bill_params)
    @jxc_other_stock_in_bill.stock_in_date = stringParseDate(bill_info[:stock_in_date])
    @jxc_other_stock_in_bill.supplier_id = supplier_id
    @jxc_other_stock_in_bill.storage_id =  storage_id
    #制单人
    @jxc_other_stock_in_bill.bill_maker <<  current_user
    #经手人信息
    @jxc_other_stock_in_bill.handler << current_user

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
      tempBillDetail.resource_product_id = billDetailInfo[:product_id]
      #商品计量单位
      tempBillDetail.unit = billDetailInfo[:unit]
      #备注
      tempBillDetail.remark = billDetailInfo[:remark]

      #商品来源（供应商）
      tempBillDetail.unit_id = supplier_id
      #商品明细 所属单据
      tempBillDetail.other_in_bill_id = @jxc_other_stock_in_bill._id
      #商品 入库仓库
      tempBillDetail.storage_id = storage_id

      tempBillDetail.save
    end

    respond_to do |format|
      if @jxc_other_stock_in_bill.save
        # format.html { redirect_to @jxc_other_stock_in_bill, notice: '其他入库单已经成功创建.' }
        format.js { render_js jxc_other_stock_in_bill_path(@jxc_other_stock_in_bill), notice: '其他入库单已经成功创建.' }
        format.json { render :show, status: :created, location: @jxc_other_stock_in_bill }
      else
        # format.html { render :new }
        format.js { render_js new_jxc_other_stock_in_bill_path }
        format.json { render json: @jxc_other_stock_in_bill.errors, status: :unprocessable_entity }
      end
    end
  end

  def update

    if @jxc_other_stock_in_bill.bill_status == '0'
      bill_info = params[:jxc_other_stock_in_bill]
      #供应商
      supplier_id = bill_info[:supplier_id]
      #仓库
      storage_id = bill_info[:storage_id]
      #经手人
      # handler_id = bill_info[:handler_id]

      @jxc_other_stock_in_bill.supplier_id = supplier_id
      @jxc_other_stock_in_bill.storage_id =  storage_id
      #制单人
      @jxc_other_stock_in_bill.bill_maker << current_user
      #经手人信息
      @jxc_other_stock_in_bill.handler << current_user


      @jxc_other_stock_in_bill.customize_bill_no = bill_info[:customize_bill_no]
      @jxc_other_stock_in_bill.stock_in_type = bill_info[:stock_in_type]
      @jxc_other_stock_in_bill.stock_in_date = stringParseDate(bill_info[:stock_in_date])
      @jxc_other_stock_in_bill.remark = bill_info[:remark]

      #先删除单据以前的商品详情
      JxcBillDetail.where(other_in_bill_id: @jxc_other_stock_in_bill.id).destroy

      #单据商品明细
      billDetailArray = params[:billDetail]
      billDetailArray.each do |billDetailInfo|
        tempBillDetail = JxcBillDetail.new

        #单价
        price = billDetailInfo[:price] == '' ? 0.00 : billDetailInfo[:price]
        #数量
        count = billDetailInfo[:count] == '' ? 0 : billDetailInfo[:count]
        #金额
        amount = tempBillDetail.calculate_amount(price,count)

        tempBillDetail.price = price
        tempBillDetail.count = count
        tempBillDetail.amount = amount

        #商品ID
        tempBillDetail.resource_product_id = billDetailInfo[:product_id]
        #商品计量单位
        tempBillDetail.unit = billDetailInfo[:unit]
        #备注
        tempBillDetail.remark = billDetailInfo[:remark]

        #商品来源（供应商）
        tempBillDetail.unit_id = supplier_id
        #商品明细 所属单据
        tempBillDetail.other_in_bill_id = @jxc_other_stock_in_bill._id
        #商品 入库仓库
        tempBillDetail.storage_id = storage_id

        tempBillDetail.save
      end

      respond_to do |format|
        if @jxc_other_stock_in_bill.update
          # format.html { redirect_to @jxc_other_stock_in_bill, notice: '其他入库单已经成功更新.' }
          format.js { render_js jxc_other_stock_in_bill_path(@jxc_other_stock_in_bill), notice: '其他入库单已经成功更新.' }
          format.json { render :show, status: :ok, location: @jxc_other_stock_in_bill }
        else
          # format.html { render :edit }
          format.js { render_js edit_jxc_other_stock_in_bill_path(@jxc_other_stock_in_bill) }
          format.json { render json: @jxc_other_stock_in_bill.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  def destroy
    @jxc_other_stock_in_bill.destroy
    respond_to do |format|
      # format.html { redirect_to jxc_other_stock_in_bills_url, notice: '其他入库单已经成功删除.' }
      format.js { render_js jxc_other_stock_in_bills_url, notice: '其他入库单已经成功删除.' }
      format.json { head :no_content }
    end
  end

  #审核
  def audit
    result = @jxc_other_stock_in_bill.audit(current_user)
    render json: result
  end

  #冲账
  def strike_a_balance
    result = @jxc_other_stock_in_bill.strike_a_balance(current_user)
    render json: result
  end

  #作废
  def invalid
    result = @jxc_other_stock_in_bill.bill_invalid
    render json: result
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_jxc_other_stock_in_bill
    @jxc_other_stock_in_bill = JxcOtherStockInBill.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def jxc_other_stock_in_bill_params
    params.require(:jxc_other_stock_in_bill).permit(:bill_no, :customize_bill_no, :stock_in_date, :stock_in_type, :remark, :bill_status)
  end

  def set_bill_details
    @bill_details = JxcBillDetail.where(:other_in_bill_id => @jxc_other_stock_in_bill.id)
  end

  def set_stock_in_types
    @stock_in_types = JxcDictionary.where(:dic_desc => 'stock_in_type')
  end
end
