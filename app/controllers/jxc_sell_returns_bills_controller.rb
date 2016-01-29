class JxcSellReturnsBillsController < ApplicationController
  before_action :set_jxc_sell_returns_bill, only: [:show, :edit, :update, :destroy, :audit, :strike_a_balance, :invalid]
  before_action :set_bill_details, only:[:show, :edit]

  def index
    @jxc_sell_returns_bills = JxcSellReturnsBill.includes(:jxc_storage,:handler).where(:bill_status.ne => '-1').order_by(:created_at => :desc).page(params[:page]).per(10)
  end

  def show
    @operation = 'show'
    #单据状态展示
    billStatus = @jxc_sell_returns_bill.bill_status
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
    @jxc_sell_returns_bill = JxcSellReturnsBill.new
    @jxc_sell_returns_bill.bill_no = @jxc_sell_returns_bill.generate_bill_no
    @jxc_sell_returns_bill.refund_date = Time.now
    @jxc_sell_returns_bill.returns_date = Time.now
    @jxc_sell_returns_bill.handler << current_user
  end

  def edit
  end

  def create

    bill_info = params[:jxc_sell_returns_bill]
    consumer_id = bill_info[:consumer_id]   #客户ID
    storage_id = bill_info[:storage_id]    #入货仓库ID
    # handler_id = bill_info[:handler_id]   #经手人ID
    # account_id = bill_info[:account_id]   #付款账户ID

    @jxc_sell_returns_bill = JxcSellReturnsBill.new(jxc_sell_returns_bill_params)

    @jxc_sell_returns_bill.consumer_id = consumer_id
    @jxc_sell_returns_bill.storage_id =  storage_id
    # @jxc_sell_returns_bill.account_id =  account_id
    #制单人
    @jxc_sell_returns_bill.bill_maker <<  current_user
    #经手人信息
    @jxc_sell_returns_bill.handler <<  current_user

    @jxc_sell_returns_bill.refund_date = stringParseDate(bill_info[:refund_date])
    @jxc_sell_returns_bill.returns_date = stringParseDate(bill_info[:returns_date])

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

      #商品退货单价
      price = billDetailInfo[:price] == '' ? 0.00 : billDetailInfo[:price]
      #数量
      count = billDetailInfo[:count] == '' ? 0 : billDetailInfo[:count]
      #金额
      amount = tempBillDetail.calculate_discount_amount(price,count,discount)

      #退货单价
      tempBillDetail.price = price
      #退货数量
      tempBillDetail.count = count
      #金额
      tempBillDetail.amount = amount

      #商品ID
      tempBillDetail.resource_product_id = billDetailInfo[:product_id]
      #商品计量单位
      tempBillDetail.unit = billDetailInfo[:unit]
      #备注
      tempBillDetail.remark = billDetailInfo[:remark]

      #客户
      tempBillDetail.unit_id = consumer_id
      #商品明细 所属单据
      tempBillDetail.sell_returns_bill_id = @jxc_sell_returns_bill._id
      #商品 入库仓库
      tempBillDetail.storage_id = storage_id

      tempBillDetail.save
      #单据合计金额累加
      total_amount += amount
    end

    #本次退款
    @jxc_sell_returns_bill.current_refund = bill_info[:current_refund].to_d
    #单据折扣
    @jxc_sell_returns_bill.discount = discount
    #优惠金额
    @jxc_sell_returns_bill.discount_amount = discount_amount.to_d
    #单据总金额
    @jxc_sell_returns_bill.total_amount = total_amount.to_d
    #单据应退款
    @jxc_sell_returns_bill.refund_amount = @jxc_sell_returns_bill.calculate_bill_amount(total_amount,discount_amount)

    respond_to do |format|
      if @jxc_sell_returns_bill.save
        # format.html { redirect_to jxc_sell_returns_bills_path, notice: '销售退货单已经成功创建.' }
        format.js { render_js jxc_sell_returns_bills_path, notice: '销售退货单已经成功创建.' }
        format.json { render :show, status: :created, location: @jxc_sell_returns_bill }
      else
        # format.html { render :new }
        format.html { render_js new_jxc_sell_returns_bill_path }
        format.json { render json: @jxc_sell_returns_bill.errors, status: :unprocessable_entity }
      end
    end
  end



  def update
    #判断，只有单据处于 已创建 状态时，才可修改
    if @jxc_sell_returns_bill.bill_status == '0'
      bill_info = params[:jxc_sell_returns_bill]
      consumer_id = bill_info[:consumer_id]   #供应商ID
      storage_id = bill_info[:storage_id]    #入货仓库ID
      # handler_id = bill_info[:handler_id]   #经手人ID
      # account_id = bill_info[:account_id]   #付款账户ID


      @jxc_sell_returns_bill.consumer_id = consumer_id
      @jxc_sell_returns_bill.storage_id =  storage_id
      # @jxc_sell_returns_bill.account_id =  account_id
      #制单人
      @jxc_sell_returns_bill.bill_maker << current_user
      #经手人信息
      @jxc_sell_returns_bill.handler << current_user

      @jxc_sell_returns_bill.customize_bill_no = bill_info[:customize_bill_no]
      @jxc_sell_returns_bill.refund_date = stringParseDate(bill_info[:refund_date])
      @jxc_sell_returns_bill.returns_date = stringParseDate(bill_info[:returns_date])
      @jxc_sell_returns_bill.current_refund = bill_info[:current_refund]
      @jxc_sell_returns_bill.remark = bill_info[:remark]

      #单据合计金额
      total_amount = 0
      #整单折扣
      discount = bill_info[:discount] == '' ? 100 : bill_info[:discount]
      #整单优惠
      discount_amount = bill_info[:discount_amount] == '' ? 0 : bill_info[:discount_amount]

      #先删除单据以前的商品详情
      JxcBillDetail.where(sell_returns_bill_id: @jxc_sell_returns_bill.id).destroy

      #单据商品明细
      billDetailArray = params[:billDetail]
      billDetailArray.each do |billDetailInfo|
        tempBillDetail = JxcBillDetail.new

        #商品退货单价
        price = billDetailInfo[:price] == '' ? 0.00 : billDetailInfo[:price]
        #数量
        count = billDetailInfo[:count] == '' ? 0 : billDetailInfo[:count]
        #金额
        amount = tempBillDetail.calculate_discount_amount(price,count,discount)

        #退货单价
        tempBillDetail.price = price
        #退货数量
        tempBillDetail.count = count
        #金额
        tempBillDetail.amount = amount

        #商品ID
        tempBillDetail.resource_product_id = billDetailInfo[:product_id]
        #商品计量单位
        tempBillDetail.unit = billDetailInfo[:unit]
        #备注
        tempBillDetail.remark = billDetailInfo[:remark]

        #客户
        tempBillDetail.unit_id = consumer_id
        #商品明细 所属单据
        tempBillDetail.sell_returns_bill_id = @jxc_sell_returns_bill._id
        #商品 入库仓库
        tempBillDetail.storage_id = storage_id

        tempBillDetail.save
        #单据合计金额累加
        total_amount += amount
      end

      #本次退款
      @jxc_sell_returns_bill.current_refund = bill_info[:current_refund].to_d
      #单据折扣
      @jxc_sell_returns_bill.discount = discount
      #优惠金额
      @jxc_sell_returns_bill.discount_amount = discount_amount.to_d
      #单据总金额
      @jxc_sell_returns_bill.total_amount = total_amount.to_d
      #单据应退款
      @jxc_sell_returns_bill.refund_amount = @jxc_sell_returns_bill.calculate_bill_amount(total_amount,discount_amount)


      respond_to do |format|
        if @jxc_sell_returns_bill.update
          # format.html { redirect_to @jxc_sell_returns_bill, notice: '销售退货单已经成功更新.' }
          format.js { render_js edit_jxc_sell_returns_bill_path(@jxc_sell_returns_bill), notice: '销售退货单已经成功更新.' }
          format.json { render :show, status: :ok, location: @jxc_sell_returns_bill }
        else
          # format.html { render :edit }
          format.js { render_js edit_jxc_sell_returns_bill_path(@jxc_sell_returns_bill) }
          format.json { render json: @jxc_sell_returns_bill.errors, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        # format.html {redirect_to @jxc_sell_returns_bill, notice: '销售退货单当前状态无法更新.'}
        format.js { render_js jxc_sell_returns_bill_path(@jxc_sell_returns_bill), notice: '销售退货单当前状态无法更新.'}
      end
    end
  end

  def destroy
    @jxc_sell_returns_bill.destroy
    respond_to do |format|
      # format.html { redirect_to jxc_sell_returns_bills_url, notice: '销售退货单已经成功删除.' }
      format.js { render_js jxc_sell_returns_bills_url, notice: '销售退货单已经成功删除.' }
      format.json { head :no_content }
    end
  end


  #单据审核
  def audit
    result = @jxc_sell_returns_bill.audit(current_user)
    render json:result
  end

  #单据冲账
  def strike_a_balance
    result = @jxc_sell_returns_bill.strike_a_balance(current_user)
    render json:result
  end

  #单据作废
  def invalid
    result = @jxc_sell_returns_bill.invalid
    render json:result
  end

  private
  def set_jxc_sell_returns_bill
    @jxc_sell_returns_bill = JxcSellReturnsBill.find(params[:id])
  end

  def jxc_sell_returns_bill_params
    params.require(:jxc_sell_returns_bill).permit(:bill_no, :customize_bill_no, :refund_date, :returns_date, :current_refund, :remark, :total_amount, :discount, :discount_amount, :refund_amount, :bill_status)
  end

  #设置单据明细
  def set_bill_details
    @bill_details = JxcBillDetail.where(sell_returns_bill_id: @jxc_sell_returns_bill.id)
  end
end
