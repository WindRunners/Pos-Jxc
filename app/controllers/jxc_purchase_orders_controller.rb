class JxcPurchaseOrdersController < ApplicationController
  before_action :set_jxc_purchase_order, only: [:show, :edit, :update, :destroy, :audit, :strike_a_balance, :invalid]

  def index
    @jxc_purchase_orders = JxcPurchaseOrder.includes(:jxc_storage,:handler).where(:bill_status.ne => '-1').order_by(:created_at => :desc).page(params[:page]).per(10)
  end

  def show
    @bill_details = JxcBillDetail.where(purchase_order_id: @jxc_purchase_order.id)
    @operation = 'show'
    #单据状态展示
    billStatus = @jxc_purchase_order.bill_status
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
    @jxc_purchase_order = JxcPurchaseOrder.new
    @jxc_purchase_order.order_no = @jxc_purchase_order.generate_order_no
    @jxc_purchase_order.order_date = Time.now
    @jxc_purchase_order.receive_goods_date = Time.now
    @jxc_purchase_order.handler << current_user
  end

  def edit
    @bill_details = JxcBillDetail.where(purchase_order_id: @jxc_purchase_order.id)
  end

  def create
    purchase_order_info = params[:jxc_purchase_order]
    supplier_id = purchase_order_info[:supplier_id]   #供应商ID
    storage_id = purchase_order_info[:storage_id]    #入货仓库ID
    # account_id = purchase_order_info[:account_id]   #付款账户ID

    @jxc_purchase_order = JxcPurchaseOrder.new(jxc_purchase_order_params)
    @jxc_purchase_order.supplier_id = supplier_id
    @jxc_purchase_order.storage_id = storage_id
    # @jxc_purchase_order.account_id = account_id
    #制单人
    @jxc_purchase_order.bill_maker << current_user
    #经手人
    @jxc_purchase_order.handler << current_user

    @jxc_purchase_order.order_date = stringParseDate(purchase_order_info[:order_date])
    @jxc_purchase_order.receive_goods_date = stringParseDate(purchase_order_info[:receive_goods_date])

    total_amount = 0    #单据合计金额
    discount = purchase_order_info[:discount] == '' ? 100 : purchase_order_info[:discount]         #整单折扣
    discount_amount = purchase_order_info[:discount_amount] == '' ? 0 : purchase_order_info[:discount_amount]   #整单优惠

    billDetailArray = params[:billDetail] #单据商品明细
    billDetailArray.each do |billDetailInfo|
      tempBillDetail = JxcBillDetail.new

      purchasePrice = billDetailInfo[:purchase_price] == '' ? 0.00 : billDetailInfo[:purchase_price]   #商品采购单价
      count = billDetailInfo[:count] == '' ? 0 : billDetailInfo[:count]  #采购数量
      amount = tempBillDetail.calculate_discount_amount(purchasePrice,count,discount)  #金额

      tempBillDetail.resource_product_id = billDetailInfo[:product_id]   #商品ID
      tempBillDetail.unit = billDetailInfo[:unit]       #商品计量单位
      tempBillDetail.remark = billDetailInfo[:remark]   #备注

      tempBillDetail.price = purchasePrice  #采购单价
      tempBillDetail.count = count                   #采购数量
      tempBillDetail.amount = amount                 #金额

      tempBillDetail.unit_id = supplier_id                         #商品来源（供应商）
      tempBillDetail.purchase_order_id = @jxc_purchase_order._id   #商品 所属订单
      tempBillDetail.storage_id = storage_id                       #商品 入库仓库

      receiveCount = billDetailInfo[:receive_count]   #到货数量
      otherCount = tempBillDetail.calc_other_count(count,receiveCount)  #未到货数量

      tempBillDetail[:receive_count] = receiveCount #到货数量
      tempBillDetail[:other_count] = otherCount     #未到货数量

      tempBillDetail.save
      total_amount += amount  #单据合计金额累加
    end

    @jxc_purchase_order.down_payment = purchase_order_info[:down_payment].to_d  #预付定金
    @jxc_purchase_order.discount = discount   #单据折扣
    @jxc_purchase_order.discount_amount = discount_amount.to_d    #优惠金额
    @jxc_purchase_order.total_amount = total_amount.to_d   #单据总金额
    @jxc_purchase_order.payable_amount = @jxc_purchase_order.calculate_bill_amount(total_amount,discount_amount)  #单据应付金额

    respond_to do |format|
      if @jxc_purchase_order.save
        # format.html { redirect_to jxc_purchase_orders_path, notice: '采购订单已成功创建.' }
        format.js { render_js jxc_purchase_orders_path, notice: '采购订单已成功创建.' }
        format.json { render :show, status: :created, location: @jxc_purchase_order }
      else
        # format.html { render :new }
        format.js { render_js new_jxc_purchase_order_path }
        format.json { render json: @jxc_purchase_order.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    #当且仅当单据状态为 已创建 时，才可更新单据
    if @jxc_purchase_order.bill_status == '0'

      purchase_order_info = params[:jxc_purchase_order]
      supplier_id = purchase_order_info[:supplier_id]   #供应商ID
      storage_id = purchase_order_info[:storage_id]    #入货仓库ID
      # account_id = purchase_order_info[:account_id]   #付款账户ID

      @jxc_purchase_order.supplier_id = supplier_id
      @jxc_purchase_order.storage_id = storage_id
      # @jxc_purchase_order.account_id = account_id
      #制单人
      @jxc_purchase_order.bill_maker << current_user
      #经手人
      @jxc_purchase_order.handler << current_user

      @jxc_purchase_order.customize_order_no = purchase_order_info[:customize_order_no]
      @jxc_purchase_order.order_date = stringParseDate(purchase_order_info[:order_date])
      @jxc_purchase_order.receive_goods_date = stringParseDate(purchase_order_info[:receive_goods_date])
      @jxc_purchase_order.down_payment = purchase_order_info[:down_payment]
      @jxc_purchase_order.remark = purchase_order_info[:remark]

      total_amount = 0    #单据合计金额
      discount = purchase_order_info[:discount] == '' ? 100 : purchase_order_info[:discount]         #整单折扣
      discount_amount = purchase_order_info[:discount_amount] == '' ? 0 : purchase_order_info[:discount_amount]   #整单优惠

      #先删除单据修改前的商品详情
      JxcBillDetail.where(purchase_order_id: @jxc_purchase_order.id).destroy

      #保存修改后的单据商品详情
      billDetailArray = params[:billDetail] #单据商品明细
      billDetailArray.each do |billDetailInfo|

        tempBillDetail = JxcBillDetail.new

        purchasePrice = billDetailInfo[:purchase_price] == '' ? 0.00 : billDetailInfo[:purchase_price]   #商品采购单价
        count = billDetailInfo[:count] == '' ? 0 : billDetailInfo[:count]  #采购数量
        amount = tempBillDetail.calculate_discount_amount(purchasePrice,count,discount)  #金额

        tempBillDetail.resource_product_id = billDetailInfo[:product_id]   #商品ID
        tempBillDetail.unit = billDetailInfo[:unit]       #商品计量单位
        tempBillDetail.remark = billDetailInfo[:remark]   #备注

        tempBillDetail.price = purchasePrice  #采购单价
        tempBillDetail.count = count                   #采购数量
        tempBillDetail.amount = amount                 #金额

        tempBillDetail.unit_id = supplier_id                         #商品来源（供应商）
        tempBillDetail.purchase_order_id = @jxc_purchase_order._id   #商品 所属订单
        tempBillDetail.storage_id = storage_id                       #商品 入库仓库

        receiveCount = billDetailInfo[:receive_count] #到货数量
        otherCount = tempBillDetail.calc_other_count(count,receiveCount)  #未到货数量

        tempBillDetail[:receive_count] = receiveCount
        tempBillDetail[:other_count] = otherCount

        tempBillDetail.save

        total_amount += amount  #单据合计金额累加
      end

      @jxc_purchase_order.down_payment = purchase_order_info[:down_payment].to_d  #预付定金
      @jxc_purchase_order.discount = discount   #单据折扣
      @jxc_purchase_order.discount_amount = discount_amount.to_d    #优惠金额
      @jxc_purchase_order.total_amount = total_amount.to_d   #单据总金额
      @jxc_purchase_order.payable_amount = @jxc_purchase_order.calculate_bill_amount(total_amount,discount_amount)  #单据应付金额
      @jxc_purchase_order.bill_status = purchase_order_info[:bill_status] == '' ? '0' : purchase_order_info[:bill_status] #单据状态

      respond_to do |format|
        if @jxc_purchase_order.update
          # format.html { redirect_to jxc_purchase_orders_path, notice: '采购订单已经成功更新.' }
          format.js { render_js jxc_purchase_orders_path, notice: '采购订单已经成功更新.' }
          format.json { render :show, status: :ok, location: @jxc_purchase_order }
        else
          # format.html { render :edit }
          format.js { render_js edit_jxc_purchase_order_path(@jxc_purchase_order) }
          format.json { render json: @jxc_purchase_order.errors, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        format.html {redirect_to jxc_purchase_orders_path, notice: '销售订单当前状态无法更新。'}
      end
    end
  end

  def destroy
    #删除单据时，对应的单据详情也一并删除
    JxcBillDetail.where(purchase_order_id: @jxc_purchase_order.id).destroy
    @jxc_purchase_order.destroy
    respond_to do |format|
      # format.html { redirect_to jxc_purchase_orders_url, notice: '采购订单已经成功删除.' }
      format.js { render_js jxc_purchase_orders_url, notice: '采购订单已经成功删除.' }
      format.json { head :no_content }
    end
  end

  #单据 审核
  def audit
    result = @jxc_purchase_order.audit
    render json:result
    # respond_to do |format|
    #   format.js { render_js jxc_purchase_orders_url, notice: result[:msg] }
    #   format.json { head :no_content }
    # end
  end

  #审核后的单据 红冲
  def strike_a_balance
    result = @jxc_purchase_order.strike_a_balance
    render json:result
    # respond_to do |format|
    #   format.js { render_js jxc_purchase_orders_url, notice: result[:msg] }
    #   format.json { head :no_content }
    # end
  end

  #单据 作废
  def invalid
    result = @jxc_purchase_order.bill_invalid
    render json:result
  end

  private
  def set_jxc_purchase_order
    @jxc_purchase_order = JxcPurchaseOrder.find(params[:id])
  end

  def jxc_purchase_order_params
    params.require(:jxc_purchase_order).permit(:order_no, :customize_order_no, :receive_goods_date, :order_date, :down_payment, :remark, :total_amount, :discount, :discount_amount, :payable_amount, :bill_status, :jxc_account_id)
  end
end
