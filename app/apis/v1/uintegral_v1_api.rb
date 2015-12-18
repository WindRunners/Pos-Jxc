class UintegralV1API < Grape::API
  format :json

  helpers do

    def ahoy
      @ahoy ||= Ahoy::Tracker.new
    end

    def current_user
      token = headers['Authentication-Token']
      @current_user = User.find_by(authentication_token:token)
    rescue
      error!('401 Unauthorized', 401)

    end

    def authenticate!

      error!('401 Unauthorized', 401) unless current_user
    end
  end

  desc '小b入账积分'
    params do
      requires 'id',type: String,desc: '小b的ID;积分类型(:type) 0 初始入账积分 1 充值入账积分 2 客户反馈积分 3 余额兑换积分 4 绑定积分 5 促销支出'
    end
   get :integrals do
     array=[]
     begin
       @user_integrals=UserIntegral.where(userinfo_id: params[:id],state: 1)
       @user_integrals.each do |u|
         array << {integral_no: "#{u.integral_no}",integral:"#{u.integral}",state:"已入账",type:"#{u.type}",integral_date:"#{u.integral_date.strftime('%Y-%m-%d %H:%M:%S').to_s}"}
       end
     rescue
       array << {messages: "没有数据",state:"0"}
     end
    return array
  end

  desc '小b支出积分'
  params do
    requires 'id',type: String,desc: '小b的ID;积分类型(:type) 0 初始入账积分 1 充值入账积分 2 客户反馈积分 3 余额兑换积分 4 绑定积分 5 销售支出积分'
  end
  get :integrals_spending do
    array=[]
    begin
      @user_integrals=UserIntegral.where(userinfo_id: params[:id],state: 0)
      @user_integrals.each do |u|
        array << {integral_no: "#{u.integral_no}",integral:"#{u.integral}",state:"已支出",type:"#{u.type}",integral_date:"#{u.integral_date.strftime('%Y-%m-%d %H:%M:%S').to_s}"}
      end
    rescue
      array << {messages: "没有数据",state:"0"}
    end
    return array
  end



  desc '余额转积分'
  params do
    requires 'id',type: String,desc: '小b的ID;'
    requires 'cash',type: String, desc: '现金'
  end
  post :modify_cash do
    array=[]
    begin
      @cashes = Cash.all
      @cashOrders=CashOrder.all

      @pay_totle=0.00
      @pay_o=0.00
      @pay_q=0.00
      @cash_totle=0.00
      @cashOrders.each do |cashOrder|
        if cashOrder.userinfo_id.to_s==params[:id] #完成订单
          @pay_o=cashOrder.paycost + @pay_o
        else
          @pay_o=0.00
        end
      end
      @cash_totle=0
      @cash_y=0
      @cashing_totle=0
      @cashes.each do |cash|
        if cash.cash_state == 2 && cash.userinfo_id.to_s==params[:id]
          @cash_totle=cash.cash + @cash_totle
        elsif cash.cash_state == 1 && cash.userinfo_id.to_s==params[:id]
          @cashing_totle = cash.cash + @cashing_totle
        elsif cash.cash_state == 4 && cash.userinfo_id.to_s==params[:id]
          @cash_y= cash.cash + @cash_y
        end
      end
      @pay_totle=@pay_o-(@cash_totle+@cashing_totle+@cash_y)
      cash=params[:cash].to_i
      if @pay_totle-cash >0
        @user_integral=UserIntegral.new
        @user_integral.cash=cash
        @user_integral.userinfo_id=params[:id]
        @user_integral.integral=cash*100
        @user_integral.state=1
        @user_integral.type =3
        @user_integral.save
        @cash=Cash.new
        @cash.cash =cash
        @cash.cash_state = 4
        @cash.cash_req_date=Time.now
        @cash.userinfo_id = params[:id]
        @cash.save
        array << {messages:"sucess",state:"1"}
      else
        array << {messages:"请求的余额不足",state:"0"}
      end

    rescue
      array << {messages:"余额转积分有误",state:"0"}
    end
  end


  desc '生成充值预订单', {
      headers: {
          "Authentication-Token" => {
              description: "用户Token",
              required: true
          }
      }
  }
  params do
    requires :money, type: Integer, desc: '充值金额'
    requires :paymode, type: Integer, desc: '1(支付宝) 2(微信支付)'
  end
  get 'unifiedorder' do
    authenticate!

    order = UserinfoOrder.new
    order.paymode = params[:paymode]
    order.money = params[:money]
    order.state = 0

    params = {
        body: '测试充值',
        out_trade_no: order.id.to_s
    }

    if order.paymode == 1 #支付宝
      params[:total_fee] = 0.01
      params[:subject] = '测试充值'
      params[:notify_url] = "http://www.nit.cn:4000/userinfo_orders/#{order.id}/alipay_notify"

      Rails.logger.info params

      r = Alipay::Mobile::Service.mobile_securitypay_pay_string params

      result = {
          success: 'ok',
          result: r
      }

    elsif order.paymode == 2 #微信支付
      params[:total_fee] = 1
      params[:spbill_create_ip] = request.ip
      params[:trade_type] = 'APP' # could be "JSAPI", "NATIVE" or "APP",
      params[:notify_url] = "http://www.nit.cn:4000/userinfo_orders/#{order.id}/wx_notify"

      Rails.logger.info params

      r = WxPay::Service.invoke_unifiedorder params


      if r.success?
        params = {
            prepayid: r['prepay_id'], # fetch by call invoke_unifiedorder with `trade_type` is `APP`
            noncestr: r['nonce_str'] # must same as given to invoke_unifiedorder
        }


        # call generate_app_pay_req
        r = WxPay::Service::generate_app_pay_req params
      else
        {failure:'busy, try later'}
      end
    end

  end

  desc '查询订单付款状态'
  params do
    requires :id, type: String, desc: '订单ID'
  end
  get 'check_order' do
    order = UserinfoOrder.find(params[:id])

    # order = Order.new
    # order.id = params[:id]
    # order.paymode = 2

    if order.state == 1 then
      {result:'success'}
    else
      params = {
          out_trade_no: order.id.to_s
      }

      if order.paymode == 1 then #支付宝
        r = Alipay::Service.single_trade_query params
        result = Hash.from_xml(r)["alipay"]
        if result['is_success'] == "T" then
          {result:'success'}
        else
          {result:'failure'}
        end
      else #微信支付
        r = WxPay::Service.order_query params

        if WxPay::Sign.verify?(r.as_json)

          trade_state = r['trade_state'] || ''

          if trade_state == "SUCCESS" then
            {result:'success'}
          else
            {result:'failure'}
          end
        else
          {result:'failure'}
        end
      end
    end
  end


end