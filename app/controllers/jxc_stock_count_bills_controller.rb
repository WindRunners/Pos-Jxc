class JxcStockCountBillsController < ApplicationController
  before_action :set_jxc_stock_count_bill, only: [:show, :edit, :update, :destroy, :audit_in_advance, :generate_pl_bill, :finally_confirm,:invalid]
  before_action :set_bill_details, only:[:show, :edit]

  def index
    @jxc_stock_count_bills = JxcStockCountBill.includes(:jxc_storage,:handler).where(:bill_status.ne => '-1').order_by(:created_at => :desc).page(params[:page]).per(10)
  end

  def show
    @operation = 'show'
    #单据状态展示
    billStatus = @jxc_stock_count_bill.bill_status
    @billStatus = ''
    case billStatus
      when '0'
        @billStatus = '已创建'
      when '1'
        @billStatus = '已预审'
      when '2'
        @billStatus = '已确认'
      else
        @billStatus = '已作废'
    end
  end

  def new
    @jxc_stock_count_bill = JxcStockCountBill.new
    @jxc_stock_count_bill.bill_no = @jxc_stock_count_bill.generate_bill_no
    @jxc_stock_count_bill.check_date = Time.now
    @jxc_stock_count_bill.handler << current_user
  end

  def edit
  end

  def create
    bill_info = params[:jxc_stock_count_bill]
    #仓库
    storage_id = bill_info[:storage_id]
    #经手人
    # handler_id = bill_info[:handler_id]

    @jxc_stock_count_bill = JxcStockCountBill.new(jxc_stock_count_bill_params)
    @jxc_stock_count_bill.storage_id = storage_id
    #制单人
    @jxc_stock_count_bill.bill_maker << current_user
    #经手人
    @jxc_stock_count_bill.handler << current_user

    @jxc_stock_count_bill.check_date = stringParseDate(bill_info[:check_date])

    #单据商品明细
    billDetailArray = params[:billDetail]
    billDetailArray.each do |billDetailInfo|
      tempBillDetail = JxcBillDetail.new

      #成本价
      price = billDetailInfo[:price] == '' ? 0.00 : billDetailInfo[:price]
      #库存数量
      inventory_count = billDetailInfo[:inventory_count] == '' ? 0 : billDetailInfo[:inventory_count].to_d
      #盘点数量
      check_count = billDetailInfo[:check_count] == '' ? 0 : billDetailInfo[:check_count].to_d
      #复盘数量
      recheck_count = billDetailInfo[:recheck_count] == '' ? 0 : billDetailInfo[:recheck_count].to_d
      #盈亏数量
      pl_count = recheck_count - inventory_count

      tempBillDetail.price = price
      tempBillDetail[:inventory_count] = inventory_count
      tempBillDetail[:check_count] = check_count
      tempBillDetail[:recheck_count] = recheck_count
      tempBillDetail[:pl_count] = pl_count

      #盈亏金额
      tempBillDetail[:pl_amount] = tempBillDetail.calculate_amount(price,pl_count)

      #商品ID
      tempBillDetail.resource_product_id = billDetailInfo[:product_id]
      #商品计量单位
      tempBillDetail.unit = billDetailInfo[:unit]
      #备注
      tempBillDetail.remark = billDetailInfo[:remark]

      #盘点仓库
      tempBillDetail.storage_id = storage_id
      #所属 盘点单
      tempBillDetail.stock_count_bill_id = @jxc_stock_count_bill.id

      tempBillDetail.save
    end

    respond_to do |format|
      if @jxc_stock_count_bill.save
        # format.html { redirect_to jxc_stock_count_bills_path, notice: '盘点单已经成功创建.' }
        format.js { render_js jxc_stock_count_bills_path, notice: '盘点单已经成功创建.' }
        format.json { render :show, status: :created, location: @jxc_stock_count_bill }
      else
        # format.html { render :new }
        format.js { render_js new_jxc_stock_count_bill_path }
        format.json { render json: @jxc_stock_count_bill.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @jxc_stock_count_bill.bill_status == '0'
      bill_info = params[:jxc_stock_count_bill]
      #仓库
      storage_id = bill_info[:storage_id]
      # 经手人
      # handler_id = bill_info[:handler_id]

      @jxc_stock_count_bill.storage_id = storage_id
      #制单人
      @jxc_stock_count_bill.bill_maker << current_user
      #经手人
      @jxc_stock_count_bill.handler << current_user

      @jxc_stock_count_bill.customize_bill_no = bill_info[:customize_bill_no]
      @jxc_stock_count_bill.check_date = stringParseDate(bill_info[:check_date])
      @jxc_stock_count_bill.remark = bill_info[:remark]

      #先删除单据以前的商品详情
      JxcBillDetail.where(stock_count_bill_id: @jxc_stock_count_bill.id).destroy

      #单据商品明细
      billDetailArray = params[:billDetail]
      billDetailArray.each do |billDetailInfo|
        tempBillDetail = JxcBillDetail.new

        #成本价
        price = billDetailInfo[:price] == '' ? 0.00 : billDetailInfo[:price]
        #库存数量
        inventory_count = billDetailInfo[:inventory_count] == '' ? 0 : billDetailInfo[:inventory_count].to_d
        #盘点数量
        check_count = billDetailInfo[:check_count] == '' ? 0 : billDetailInfo[:check_count].to_d
        #复盘数量
        recheck_count = billDetailInfo[:recheck_count] == '' ? 0 : billDetailInfo[:recheck_count].to_d
        #盈亏数量
        pl_count = recheck_count - inventory_count

        tempBillDetail.price = price
        tempBillDetail[:inventory_count] = inventory_count
        tempBillDetail[:check_count] = check_count
        tempBillDetail[:recheck_count] = recheck_count
        tempBillDetail[:pl_count] = pl_count

        #盈亏金额
        tempBillDetail[:pl_amount] = tempBillDetail.calculate_amount(price,pl_count)

        #商品ID
        tempBillDetail.resource_product_id = billDetailInfo[:product_id]
        #商品计量单位
        tempBillDetail.unit = billDetailInfo[:unit]
        #备注
        tempBillDetail.remark = billDetailInfo[:remark]

        #盘点仓库
        tempBillDetail.storage_id = storage_id
        #所属 盘点单
        tempBillDetail.stock_count_bill_id = @jxc_stock_count_bill.id

        tempBillDetail.save
      end

      respond_to do |format|
        if @jxc_stock_count_bill.update
          # format.html { redirect_to @jxc_stock_count_bill, notice: '盘点单已经成功更新.' }
          format.js { render_js jxc_stock_count_bill_path(@jxc_stock_count_bill), notice: '盘点单已经成功更新.' }
          format.json { render :show, status: :ok, location: @jxc_stock_count_bill }
        else
          # format.html { render :edit }
          format.js { render_js edit_jxc_stock_count_bill_path(@jxc_stock_count_bill) }
          format.json { render json: @jxc_stock_count_bill.errors, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        # format.html { redirect_to @jxc_stock_count_bill, notice: '盘点单当前状态无法修改!'}
        format.js { render_js edit_jxc_stock_count_bill_path(@jxc_stock_count_bill), notice: '盘点单当前状态无法修改!'}
      end
    end
  end

  def destroy
    @jxc_stock_count_bill.destroy
    respond_to do |format|
      # format.html { redirect_to jxc_stock_count_bills_url, notice: '盘点单已经成功删除.' }
      format.js { render_js jxc_stock_count_bills_url, notice: '盘点单已经成功删除.' }
      format.json { head :no_content }
    end
  end

  #预审核
  def audit_in_advance
    result = @jxc_stock_count_bill.audit_in_advance(current_user)
    render json:result
  end

  #生成盈亏单
  def generate_pl_bill
    result = @jxc_stock_count_bill.generate_pl_bill(current_user)
    render json:result
  end

  #最终确认
  def finally_confirm
    result = @jxc_stock_count_bill.finally_confirm(current_user)
    render json:result
  end

  #作废
  def invalid
    result = @jxc_stock_count_bill.bill_invalid
    render json:result
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_jxc_stock_count_bill
    @jxc_stock_count_bill = JxcStockCountBill.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def jxc_stock_count_bill_params
    params.require(:jxc_stock_count_bill).permit(:bill_no, :customize_bill_no, :check_date, :remark, :bill_status)
  end

  def set_bill_details
    @bill_details = JxcBillDetail.where(:stock_count_bill_id => @jxc_stock_count_bill.id)
  end
end
