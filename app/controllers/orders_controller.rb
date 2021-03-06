class OrdersController < ApplicationController
  before_action :set_order, only: [:update, :destroy]

  skip_before_action :authenticate_user!, only: [:wx_notify, :alipay_notify]



  # POST /line_order_creat
  #
  # 生成线下订单
  def line_order_creat

    orderpar = JSON.parse(params[:order])
    jxc_storage = JxcStorage.find(orderpar['storage_id'])
    ordercompleted = Ordercompleted.new(:ordertype => orderpar['ordertype'], :telephone => orderpar["telephone"], :useintegral => orderpar["useintegral"], :userinfo => current_user.userinfo, :customer_id => orderpar["customer_id"], :serial_number => orderpar["serial_number"], :business_user => orderpar['business_user'], :user_id => current_user.id, :store_id => jxc_storage['store_id'])

    respond_to do |format|

      begin

        msg = ""
        flag = true

        orderpar["ordergoods"].each do |ordergoodcompleted|
          product_id = ordergoodcompleted['product_id']
          quantity = ordergoodcompleted['quantity']
          if JxcStorageProductDetail.where({'resource_product_id' => product_id, 'jxc_storage_id' => jxc_storage.id, 'count' => {'$gte' => quantity}}).count() == 0
            product = Product.shop_id(current_user['userinfo_id']).find(product_id)
            msg = "商品【#{product.title}】库存不足！"
            flag = false
            break
          end
        end

        if flag
          format.json { render :json => {:success => true} } if ordercompleted.line_order_creat_do(orderpar)
        else
          format.json { render :json => {:success => false, :msg => msg} }
        end
      rescue Exception => e
        Rails.logger.info "线下订单生成失败，异常信息为：#{e.message}"
        format.json { render :json => {:success => false, :msg => "服务器端异常！"} }
      end
    end

  end


  # GET /orders
  # GET /orders.json
  def index

    @state = "all"
    # @order_state_count = OrderStateCount.build_orderStateCount(current_user)
  end


  def orders_table_data

    ordertype = params[:ordertype]
    parm = Hash.new
    parm[:userinfo_id] = current_user['userinfo_id']
    parm[:store_id] = {"$in" => current_user['store_ids'].present? ? current_user['store_ids'] : []} if ordertype!="0" && ordertype!="2"

    parm[:orderno] = params[:orderno] if !params[:orderno].nil? && !params[:orderno].blank?
    parm[:consignee] = params[:consignee] if !params[:consignee].nil? && !params[:consignee].blank?
    parm[:telephone] = params[:telephone] if !params[:telephone].nil? && !params[:telephone].blank?
    parm[:ordertype] = ordertype.to_i if ordertype.present?
    parm[:paymode] = params[:paymode] if !params[:paymode].nil? && !params[:paymode].blank?
    parm[:created_at.gte] = params[:beginTime] if !params[:beginTime].nil? && !params[:beginTime].blank?
    parm[:created_at.lte] = params[:endTime] if !params[:endTime].nil? && !params[:endTime].blank?
    parm[:business_user] = /#{params[:business_user]}/ if params[:business_user].present?


    state_parm = params[:workflow_state].to_sym if !params[:workflow_state].nil?

    orders = []
    if :cancelled == state_parm || :completed == state_parm || ordertype=="0" || ordertype=="2"

      parm[:workflow_state] = state_parm if :all!=state_parm
      ordercompleteds = Ordercompleted.where(parm).order(created_at: :desc)

      ordercompleteds.page(params[:page]).per(5).each do |ordercompleted|
        ordercompleted['ordergoods'] = ordercompleted.ordergoodcompleteds
        orders << ordercompleted
        # order = Order.new(ordercompleted.as_json)
        # ordercompleted.ordergoodcompleteds.each do |ordergoodcompleted|
        #   order.ordergoods.build(ordergoodcompleted.as_json(:except => [:ordercompleted_id]))
        # end
        # orders << order
      end
      @orders = Kaminari.paginate_array(orders, total_count: ordercompleteds.count()).page(params[:page]).per(5)
    elsif :generation == state_parm || :paid == state_parm || :distribution == state_parm || :receive == state_parm || :take == state_parm
      parm.delete :store_id if :generation == state_parm #待付款时移除门店限制

      parm[:workflow_state] = state_parm
      orders = Order.where(parm).order(created_at: :desc)
      @orders = orders.page(params[:page]).per(5)
    else

      @orders  = Order.get_all_orders(parm,params[:page],5)
      # @orders = Kaminari.paginate_array(orders, total_count: orders.size).page(params[:page]).per(5)
    end

    # @order_state_count = OrderStateCount.build_orderStateCount(parm[:userinfo].id)

    render :partial => 'orders_table_data', :layout => false
  end



  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  # 接单和修改的控制方法
  def receive_order

    @order = Order.find(params[:order_id])
    @order.receive_order!

    render :show, notice: '接单成功！'

  end

  # GET /orders/1
  # GET /orders/1.json
  def show
    @order = nil

    begin
      @order = Order.find(params[:id])
    rescue
      ordercompleted = Ordercompleted.find(params[:id])
      ordercompleted['ordergoods'] = ordercompleted.ordergoodcompleteds
      # order = Order.new(ordercompleted.as_json)
      # ordercompleted.ordergoodcompleteds.each do |ordergoodcompleted|
      #   order.ordergoods.build(ordergoodcompleted.as_json(:except => [:ordercompleted_id]))
      # end
      @order = ordercompleted
    end

    @delivery_user = DeliveryUser.where({"_id" => BSON::ObjectId("#{@order['delivery_user_id']}")}).first if @order['delivery_user_id'].present?
    @store = Store.where({"_id" => @order['store_id']}).first if @order['store_id'].present?

    @show_button = true
  end



  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  # 接单和修改的控制方法
  def distribution_completed
    @order = Order.find(params[:order_id])
    @order.receive_goods!

    render :show, notice: '配送完成！'

  end


  def order_state_count
    render json: OrderStateCount.build_orderStateCount(current_user)
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    @order.destroy
    respond_to do |format|
      format.html { redirect_to orders_url, notice: 'Order was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def wx_notify
    result = Hash.from_xml(request.body.read)["xml"]

    payment = WxPayment.new(result)
    payment.save!

    order = Order.find(params[:id])

    if order.workflow_state == 'paid' then
      render :xml => {return_code: "SUCCESS"}.to_xml(root: 'xml', dasherize: false)
      return
    end

    if WxPay::Sign.verify?(result)

      logger.info result

      if order.workflow_state == 'generation' && order.paymode == 2 then
        order.payment_order!
        render :xml => {return_code: "SUCCESS"}.to_xml(root: 'xml', dasherize: false)
        return
      end

      render :xml => {return_code: "FAIL", return_msg: "签名失败"}.to_xml(root: 'xml', dasherize: false)
    else
      render :xml => {return_code: "FAIL", return_msg: "签名失败"}.to_xml(root: 'xml', dasherize: false)
    end
  end

  def alipay_notify


    order_id = params.delete(:id)

    payment = AlipayPayment.new(alipay_payment_params)
    payment.save!

    begin
      order = Order.find(order_id)
    rescue
      order = Ordercompleted.find(order_id)
    end

    if order.workflow_state == 'paid'
      render plain: "success"
      return
    end

    if 'REFUND_SUCCESS' == payment.refund_status
      order.update_attribute(:refund_at, Time.now)

      logger.info 'refund success'

      render plain: "success"
      return
    end

    notify_params = params.except(*request.path_parameters.keys)

    if Alipay::Notify.verify?(notify_params)

      if order.workflow_state == 'generation' && order.paymode == 1 then
        order.payment_order!
        render plain: "success"
        return
      end

      render plain: "fail"
    else
      render plain: "fail"
    end
  end

  def alipay_refund_notify
    logger.info params

    refund = AlipayPaymentRefund.new(alipay_payment_refund_params)

    refund.save!

    render plain: "success"
  end

  def alipay_dback_notify
    logger.info params
  end

  def statisticData
    dates = params[:retailDateRang].split(" - ") if params[:retailDateRang].present?
    if dates.blank?
      today = Time.now
      dates = [today.beginning_of_month.strftime("%Y-%m-%d")]
      dates << (today - 1.day).strftime("%Y-%m-%d")
    end
    Rails.logger.info "dates===////#{dates}"
    @options = {:xAxis => {:labels => {:rotation => -45, :align => :right}, :dateTimeLabelFormats => {:month => '%Y年%b月', :day => '%b月%e日', :week => '%b月%e日'}}}
    @options[:title] = {:text => "订单交易趋势"}
    @options[:tooltip] = {:dateTimeLabelFormats => {:hour => "%Y年%b月%e日 %A"}}
    @orderStatistics = OrderStatistic.where(:userinfo_id => current_user.userinfo.id.to_s, :complete_date => {"$gte" => dates[0], "$lte" => dates[1]})
    # @orderStatistics = OrderStatistic.where(:userinfo_id => current_user.userinfo.id.to_s)
    @orderPersonNum = @orderStatistics.distinct(:customer_id).count
    @orderNum = @orderStatistics.count
    @orderAmount = 0.00
    @orderStatistics.each {|os| @orderAmount += os.total_price}
    @data = [{:name => "下单笔数", :data => @orderStatistics.group_by_day(&:complete_date).map {|k, v| [k, v.size]}}]
    Rails.logger.info "ordersStatisticData===///#{@data}"
    render :layout => false
  end

  def statistic
    
  end

  def line_payment_order

    ordercompleted = Ordercompleted.find(params[:id])
    respond_to do |format|
      flag = params[:flag] #0:拒收，1：结算
      if flag == "0"
        if ordercompleted.cancel_order!
          format.json { render json: {:flag => '1', :msg => '挂账订单拒收成功！'} }
        else
          format.json { render json: {:flag => '0', :msg => '挂账订单拒收失败！'} }
        end
      else

        if ordercompleted.payment_order!
          format.json { render json: {:flag => '1', :msg => '挂账订单结算成功！'} }
        else
          format.json { render json: {:flag => '0', :msg => '挂账订单结算失败！'} }
        end
      end
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_order
    @order = Order.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def order_params
    params.require(:order).permit(:orderno, :ordertype, :orderstatus, :modifymark, :consignee, :address, :telephone, ordergoods_attributes: [:quantity])
  end

  def alipay_payment_params
    params.permit(:discount, :payment_type, :subject, :trade_no, :buyer_email,
         :gmt_create, :notify_type, :out_trade_no, :seller_id, :notify_time, :body, :trade_status, :is_total_fee_adjust,
         :total_fee, :gmt_payment, :seller_email, :price, :buyer_id, :notify_id, :use_coupon, :sign_type, :sign)
  end
end
