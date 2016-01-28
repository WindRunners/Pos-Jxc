class JxcSellOrdersController < ApplicationController
  before_action :set_jxc_sell_order, only: [:show, :edit, :update, :destroy, :audit, :strike_a_balance, :invalid]
  before_action :set_bill_details, only: [:show,:edit]

  def index
    @jxc_sell_orders = JxcSellOrder.where(:bill_status.ne => '-1').order_by(:created_at => :desc).page(params[:page]).per(10)
  end

  def show
    @operation = 'show'
    #单据状态展示
    billStatus = @jxc_sell_order.bill_status
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
    @jxc_sell_order = JxcSellOrder.new
    @jxc_sell_order.order_no = @jxc_sell_order.generate_bill_no
    @jxc_sell_order.consign_goods_date = Time.now
    @jxc_sell_order.order_date = Time.now
    @jxc_sell_order.handler << current_user
  end

  def edit
  end

  def create
    sell_order_info = params[:jxc_sell_order]
    consumer_id = sell_order_info[:consumer_id]   #客户ID
    storage_id = sell_order_info[:storage_id]    #入货仓库ID
    # handler_id = sell_order_info[:handler_id]   #经手人ID
    # account_id = sell_order_info[:account_id]   #付款账户ID

    @jxc_sell_order = JxcSellOrder.new(jxc_sell_order_params)
    @jxc_sell_order.consumer_id = consumer_id
    @jxc_sell_order.storage_id = storage_id
    # @jxc_sell_order.account_id = account_id
    #制单人
    @jxc_sell_order.bill_maker << current_user
    #经手人
    @jxc_sell_order.handler << current_user

    @jxc_sell_order.order_date = stringParseDate(sell_order_info[:order_date])
    @jxc_sell_order.consign_goods_date = stringParseDate(sell_order_info[:consign_goods_date])

    #单据合计金额
    total_amount = 0
    #整单折扣
    discount = sell_order_info[:discount] == '' ? 100 : sell_order_info[:discount]
    #整单优惠
    discount_amount = sell_order_info[:discount_amount] == '' ? 0 : sell_order_info[:discount_amount]

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

      tempBillDetail.unit_id = consumer_id                         #客户  <商品去向>
      tempBillDetail.sell_order_id = @jxc_sell_order._id           #商品 所属订单 <单据>
      tempBillDetail.storage_id = storage_id                       #商品 出库仓库 <商品来源>

      dispatch_count = billDetailInfo[:dispatch_count]   #发货数量
      otherCount = tempBillDetail.calc_other_count(count,dispatch_count)  #未发货数量

      tempBillDetail[:dispatch_count] = dispatch_count #发货数量
      tempBillDetail[:other_count] = otherCount     #未发货数量

      tempBillDetail.save
      total_amount += amount  #单据合计金额累加
    end

    @jxc_sell_order.receivable_deposit = sell_order_info[:receivable_deposit].to_d  #预收定金
    @jxc_sell_order.discount = discount   #单据折扣
    @jxc_sell_order.discount_amount = discount_amount.to_d    #优惠金额
    @jxc_sell_order.total_amount = total_amount.to_d   #单据总金额
    @jxc_sell_order.receivable_amount = @jxc_sell_order.calculate_bill_amount(total_amount,discount_amount)  #单据应付金额


    respond_to do |format|
      if @jxc_sell_order.save
        # format.html { redirect_to jxc_sell_orders_path, notice: '销售订单已经成功创建.' }
        format.js { render_js jxc_sell_orders_path, notice: '销售订单已经成功创建.' }
        format.json { render :show, status: :created, location: @jxc_sell_order }
      else
        # format.html { render :new }
        format.js { render_js new_jxc_sell_order_path }
        format.json { render json: @jxc_sell_order.errors, status: :unprocessable_entity }
      end
    end
  end

  def update

    if @jxc_sell_order.bill_status == '0'
      sell_order_info = params[:jxc_sell_order]
      consumer_id = sell_order_info[:consumer_id]   #客户ID
      storage_id = sell_order_info[:storage_id]    #入货仓库ID
      # handler_id = sell_order_info[:handler_id]   #经手人ID
      # account_id = sell_order_info[:account_id]   #付款账户ID

      @jxc_sell_order.consumer_id = consumer_id
      @jxc_sell_order.storage_id = storage_id
      # @jxc_sell_order.account_id = account_id
      #制单人
      @jxc_sell_order.bill_maker << current_user
      #经手人
      @jxc_sell_order.handler << current_user

      @jxc_sell_order.customize_order_no = sell_order_info[:customize_order_no]
      @jxc_sell_order.order_date = stringParseDate(sell_order_info[:order_date])
      @jxc_sell_order.consign_goods_date = stringParseDate(sell_order_info[:consign_goods_date])
      @jxc_sell_order.remark = sell_order_info[:remark]

      #单据合计金额
      total_amount = 0
      #整单折扣
      discount = sell_order_info[:discount] == '' ? 100 : sell_order_info[:discount]
      #整单优惠
      discount_amount = sell_order_info[:discount_amount] == '' ? 0 : sell_order_info[:discount_amount]

      #删除之前的单据详情，添加新的
      JxcBillDetail.where(sell_order_id: @jxc_sell_order.id).destroy

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

        tempBillDetail.unit_id = consumer_id                         #客户  <商品去向>
        tempBillDetail.sell_order_id = @jxc_sell_order._id           #商品 所属订单 <单据>
        tempBillDetail.storage_id = storage_id                       #商品 出库仓库 <商品来源>

        dispatch_count = billDetailInfo[:dispatch_count]   #发货数量
        otherCount = tempBillDetail.calc_other_count(count,dispatch_count)  #未发货数量

        tempBillDetail[:dispatch_count] = dispatch_count #发货数量
        tempBillDetail[:other_count] = otherCount     #未发货数量

        tempBillDetail.save
        total_amount += amount  #单据合计金额累加
      end

      @jxc_sell_order.receivable_deposit = sell_order_info[:receivable_deposit].to_d  #预收定金
      @jxc_sell_order.discount = discount   #单据折扣
      @jxc_sell_order.discount_amount = discount_amount.to_d    #优惠金额
      @jxc_sell_order.total_amount = total_amount.to_d   #单据总金额
      @jxc_sell_order.receivable_amount = @jxc_sell_order.calculate_bill_amount(total_amount,discount_amount)  #单据应付金额
      @jxc_sell_order.bill_status = sell_order_info[:bill_status] == '' ? '0' : sell_order_info[:bill_status]

      respond_to do |format|
        if @jxc_sell_order.update
          # format.html { redirect_to jxc_sell_orders_path, notice: '销售订单已经成功更新' }
          format.js { render_js jxc_sell_orders_path, notice: '销售订单已经成功更新' }
          format.json { render :show, status: :ok, location: @jxc_sell_order }
        else
          # format.html { render :edit }
          format.js { render_js edit_jxc_sell_order_path(@jxc_sell_order) }
          format.json { render json: @jxc_sell_order.errors, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        # format.html {redirect_to jxc_sell_orders_path, notice: '销售订单当前状态无法更新。'}
        format.js {render_js jxc_sell_orders_path, notice: '销售订单当前状态无法更新。'}
      end
    end

  end

  def destroy
    @jxc_sell_order.destroy
    respond_to do |format|
      # format.html { redirect_to jxc_sell_orders_url, notice: '销售订单已经成功删除' }
      format.js { render_js jxc_sell_orders_url, notice: '销售订单已经成功删除' }
      format.json { head :no_content }
    end
  end

  #销售订单审核
  def audit
    result = @jxc_sell_order.audit
    render json: result
  end

  #销售订单红冲
  def strike_a_balance
    result = @jxc_sell_order.strike_a_balance
    render json: result
  end

  #销售订单作废
  def invalid
    result = @jxc_sell_order.bill_invalid
    render json: result
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_jxc_sell_order
    @jxc_sell_order = JxcSellOrder.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def jxc_sell_order_params
    params.require(:jxc_sell_order).permit(:order_no, :customize_order_no, :consign_goods_date, :order_date, :receivable_deposit, :remark, :total_amount, :discount, :discount_amount, :receivable_amount, :bill_status)
  end

  def set_bill_details
    @bill_details = JxcBillDetail.where(sell_order_id: @jxc_sell_order.id)
  end
end
