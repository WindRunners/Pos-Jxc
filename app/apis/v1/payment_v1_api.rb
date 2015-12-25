require 'grape'

class PaymentV1API < Grape::API

  format :json

  helpers do
    def ahoy
      @ahoy ||= Ahoy::Tracker.new
    end
  end

  use ApiLogger

  desc '生成预订单'
  params do
    requires :id, type: String, desc: '订单ID'
  end
  get 'unifiedorder' do
    order = Order.find(params[:id])
    # order = Order.new
    # order.paymode = 1
    # order.id = params[:id]

    params = {
        body: '测试商品',
        out_trade_no: order.id.to_s
    }

    if order.paymode == 1 #支付宝
      params[:total_fee] = 0.01
      params[:subject] = '商品主题'
      params[:notify_url] = "http://jyd.ibuluo.me:4000/orders/#{order.id}/alipay_notify"

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
      params[:notify_url] = "http://jyd.ibuluo.me:4000/orders/#{order.id}/wx_notify"

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
    order = Order.find(params[:id])

    # order = Order.new
    # order.id = params[:id]
    # order.paymode = 2

    if order.workflow_state == 'paid' then
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