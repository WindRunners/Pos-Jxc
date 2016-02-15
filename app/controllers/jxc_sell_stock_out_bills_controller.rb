class JxcSellStockOutBillsController < ApplicationController
  before_action :set_jxc_sell_stock_out_bill, only: [:show, :edit, :update, :destroy, :audit, :strike_a_balance, :invalid]
  before_action :set_bill_details, only:[:show, :edit]

  def index
    @jxc_sell_stock_out_bills = JxcSellStockOutBill.includes(:jxc_storage,:handler).where(:bill_status.ne => '-1').order_by(:created_at => :desc).page(params[:page]).per(10)
  end

  def show
    @operation = 'show'
    #单据状态展示
    billStatus = @jxc_sell_stock_out_bill.bill_status
    @billStatus = ''
    case billStatus
      when '-2'
        @billStatus = '未通过审核'
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
    @jxc_sell_stock_out_bill = JxcSellStockOutBill.new
    @jxc_sell_stock_out_bill.bill_no = @jxc_sell_stock_out_bill.generate_bill_no
    @jxc_sell_stock_out_bill.stock_out_date = Time.now
    @jxc_sell_stock_out_bill.collection_date = Time.now
    @jxc_sell_stock_out_bill.handler << current_user
  end

  def edit
  end

  def create
    bill_info = params[:jxc_sell_stock_out_bill]
    consumer_id = bill_info[:consumer_id]   #客户ID
    storage_id = bill_info[:storage_id]    #入货仓库ID
    # handler_id = bill_info[:handler_id]   #经手人ID
    # account_id = bill_info[:account_id]   #付款账户ID

    @jxc_sell_stock_out_bill = JxcSellStockOutBill.new(jxc_sell_stock_out_bill_params)
    @jxc_sell_stock_out_bill.consumer_id = consumer_id
    @jxc_sell_stock_out_bill.storage_id = storage_id
    # @jxc_sell_stock_out_bill.account_id = account_id
    #制单人
    @jxc_sell_stock_out_bill.bill_maker << current_user
    #经手人
    @jxc_sell_stock_out_bill.handler << current_user

    @jxc_sell_stock_out_bill.collection_date = stringParseDate(bill_info[:collection_date])
    @jxc_sell_stock_out_bill.stock_out_date = stringParseDate(bill_info[:stock_out_date])

    #单据合计金额
    total_amount = 0
    #整单折扣
    discount = bill_info[:discount] == '' ? 100 : bill_info[:discount]
    #整单优惠
    discount_amount = bill_info[:discount_amount] == '' ? 0 : bill_info[:discount_amount]

    #单据商品明细
    billDetailArray = params[:billDetail]
    billDetailArray.each do |billDetailInfo|
      tempBillDetail = JxcBillDetail.new

      sellPrice = billDetailInfo[:price] == '' ? 0.00 : billDetailInfo[:price]   #商品销售单价
      count = billDetailInfo[:count] == '' ? 0 : billDetailInfo[:count]  #销售数量
      amount = tempBillDetail.calculate_discount_amount(sellPrice,count,discount)  #金额

      tempBillDetail.resource_product_id = billDetailInfo[:product_id]   #商品ID
      tempBillDetail.unit = billDetailInfo[:unit]       #商品计量单位
      tempBillDetail.remark = billDetailInfo[:remark]   #备注

      tempBillDetail.price = sellPrice  #销售单价
      tempBillDetail.count = count      #销售数量
      tempBillDetail.amount = amount    #金额

      tempBillDetail.unit_id = consumer_id    #客户  <商品去向>
      tempBillDetail.sell_out_bill_id = @jxc_sell_stock_out_bill._id  #商品 所属订单 <单据>
      tempBillDetail.storage_id = storage_id  #商品 出库仓库 <商品来源>

      tempBillDetail.save
      total_amount += amount  #单据合计金额累加
    end

    #本次收款
    @jxc_sell_stock_out_bill.current_collection = bill_info[:current_collection].to_d
    #单据折扣
    @jxc_sell_stock_out_bill.discount = discount
    #优惠金额
    @jxc_sell_stock_out_bill.discount_amount = discount_amount.to_d
    #单据总金额
    @jxc_sell_stock_out_bill.total_amount = total_amount.to_d
    #单据应付金额
    @jxc_sell_stock_out_bill.receivable_amount = @jxc_sell_stock_out_bill.calculate_bill_amount(total_amount,discount_amount)


    respond_to do |format|
      if @jxc_sell_stock_out_bill.save
        # format.html { redirect_to jxc_sell_stock_out_bills_path, notice: '销售出库单已经成功创建.' }
        format.js { render_js jxc_sell_stock_out_bills_path, notice: '销售出库单已经成功创建.' }
        format.json { render :show, status: :created, location: @jxc_sell_stock_out_bill }
      else
        # format.html { render :new }
        format.js { render_js new_jxc_sell_stock_out_bill_path }
        format.json { render json: @jxc_sell_stock_out_bill.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    #仅当销售出库单状态为 刚创建 时，才可更新
    if @jxc_sell_stock_out_bill.bill_status == '0'

      bill_info = params[:jxc_sell_stock_out_bill]
      consumer_id = bill_info[:consumer_id]   #客户ID
      storage_id = bill_info[:storage_id]    #入货仓库ID
      # handler_id = bill_info[:handler_id]   #经手人ID
      # account_id = bill_info[:account_id]   #付款账户ID

      @jxc_sell_stock_out_bill.consumer_id = consumer_id
      @jxc_sell_stock_out_bill.storage_id = storage_id
      # @jxc_sell_stock_out_bill.account_id = account_id
      #制单人
      @jxc_sell_stock_out_bill.bill_maker << current_user
      #经手人
      @jxc_sell_stock_out_bill.handler << current_user

      @jxc_sell_stock_out_bill.customize_bill_no = bill_info[:customize_bill_no]
      @jxc_sell_stock_out_bill.collection_date = stringParseDate(bill_info[:collection_date])
      @jxc_sell_stock_out_bill.stock_out_date = stringParseDate(bill_info[:stock_out_date])
      @jxc_sell_stock_out_bill.remark = bill_info[:remark]

      #单据合计金额
      total_amount = 0
      #整单折扣
      discount = bill_info[:discount] == '' ? 100 : bill_info[:discount]
      #整单优惠
      discount_amount = bill_info[:discount_amount] == '' ? 0 : bill_info[:discount_amount]

      #删除之前的单据详情，添加新的
      JxcBillDetail.where(sell_out_bill_id:@jxc_sell_stock_out_bill.id).destroy

      #单据商品明细
      billDetailArray = params[:billDetail]
      billDetailArray.each do |billDetailInfo|
        tempBillDetail = JxcBillDetail.new

        sellPrice = billDetailInfo[:price] == '' ? 0.00 : billDetailInfo[:price]   #商品销售单价
        count = billDetailInfo[:count] == '' ? 0 : billDetailInfo[:count]  #销售数量
        amount = tempBillDetail.calculate_discount_amount(sellPrice,count,discount)  #金额

        tempBillDetail.resource_product_id = billDetailInfo[:product_id]   #商品ID
        tempBillDetail.unit = billDetailInfo[:unit]       #商品计量单位
        tempBillDetail.remark = billDetailInfo[:remark]   #备注

        tempBillDetail.price = sellPrice  #销售单价
        tempBillDetail.count = count      #销售数量
        tempBillDetail.amount = amount    #金额

        tempBillDetail.unit_id = consumer_id    #客户  <商品去向>
        tempBillDetail.sell_out_bill_id = @jxc_sell_stock_out_bill._id  #商品 所属订单 <单据>
        tempBillDetail.storage_id = storage_id  #商品 出库仓库 <商品来源>

        tempBillDetail.save
        total_amount += amount  #单据合计金额累加
      end

      #本次收款
      @jxc_sell_stock_out_bill.current_collection = bill_info[:current_collection].to_d
      #单据折扣
      @jxc_sell_stock_out_bill.discount = discount
      #优惠金额
      @jxc_sell_stock_out_bill.discount_amount = discount_amount.to_d
      #单据总金额
      @jxc_sell_stock_out_bill.total_amount = total_amount.to_d
      #单据应付金额
      @jxc_sell_stock_out_bill.receivable_amount = @jxc_sell_stock_out_bill.calculate_bill_amount(total_amount,discount_amount)
      #单据状态
      @jxc_sell_stock_out_bill.bill_status = bill_info[:bill_status] == '' ? '0' : bill_info[:bill_status]

      respond_to do |format|
        if @jxc_sell_stock_out_bill.update
          # format.html { redirect_to jxc_sell_stock_out_bills_path, notice: '销售出库单已经成功更新.' }
          format.js { render_js jxc_sell_stock_out_bills_path, notice: '销售出库单已经成功更新.' }
          format.json { render :show, status: :ok, location: @jxc_sell_stock_out_bill }
        else
          # format.html { render :edit }
          format.js { render_js edit_jxc_sell_stock_out_bill_path(@jxc_sell_stock_out_bill) }
          format.json { render json: @jxc_sell_stock_out_bill.errors, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        # format.html {redirect_to jxc_sell_stock_out_bills_path, notice: '销售出库单当前状态无法更新。'}
        format.js { render_js jxc_sell_stock_out_bills_path, notice: '销售出库单当前状态无法更新。'}
      end
    end
  end

  def destroy
    @jxc_sell_stock_out_bill.destroy
    respond_to do |format|
      # format.html { redirect_to jxc_sell_stock_out_bills_url, notice: '销售出库单已经成功删除.' }
      format.js { render_js jxc_sell_stock_out_bills_url, notice: '销售出库单已经成功删除.' }
      format.json { head :no_content }
    end
  end

  #审核
  def audit
    result = @jxc_sell_stock_out_bill.audit(current_user)
    render json:result
  end


  #冲账
  def strike_a_balance
    result = @jxc_sell_stock_out_bill.strike_a_balance(current_user)
    render json:result
  end


  #作废
  def invalid
    result = @jxc_sell_stock_out_bill.bill_invalid
    render json:result
  end

  #POS生成销售出库单，并自动审核
  # def generate_sell_out_bill
  #   result = JxcSellStockOutBill.generate_sell_out_bill(current_user)
  #   render json:result
  # end

  private
  def set_jxc_sell_stock_out_bill
    @jxc_sell_stock_out_bill = JxcSellStockOutBill.find(params[:id])
  end

  def jxc_sell_stock_out_bill_params
    params.require(:jxc_sell_stock_out_bill).permit(:bill_no, :customize_bill_no, :collection_date, :stock_out_date, :current_collection, :remark, :total_amount, :discount, :discount_amount, :receivable_amount, :bill_status)
  end

  def set_bill_details
    @bill_details = JxcBillDetail.where(sell_out_bill_id: @jxc_sell_stock_out_bill.id)
  end
end
