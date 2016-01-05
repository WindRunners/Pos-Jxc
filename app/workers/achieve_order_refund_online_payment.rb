class AchieveOrderRefundOnlinePayment

  @queue = :achieves_queue_refund_online_payment

  def self.perform(orderid)

    order = Ordercompleted.find(orderid)

    if order.paymode == 1 #支付宝退款

      batch_no = Alipay::Utils.generate_batch_no # refund batch no, you SHOULD store it to db to avoid alipay duplicate refund

      begin
        payment = AlipayPayment.find_by(out_trade_no:order.id)

        r = Alipay::Service.refund_fastpay_by_platform_nopwd(
            batch_no: batch_no,
            data: [{
                       trade_no: payment.trade_no,
                       amount: '0.01',
                       reason: '退款'
                   }],
            notify_url: "http://jyd.ibuluo.me:4000/orders/#{order.id}/alipay_refund_notify",
            dback_notify_url: "http://jyd.ibuluo.me:4000/orders/#{order.id}/alipay_dback_notify",
        )



        if r.success?
          order.update_attribute(:request_refund_at, Time.now)
          Rails.logger.info order
        else
          Resque.enqueue_at(30.seconds.from_now, AchieveOrderRefundOnlinePayment, orderid)
        end

      rescue
        Resque.enqueue_at(30.seconds.from_now, AchieveOrderRefundOnlinePayment, orderid)
      end




    elsif order.paymode == 2 #微信支付退款

      params = {
          out_trade_no: order.id.to_s,
          out_refund_no: order.id.to_s,
          total_fee: 1,
          refund_fee: 1
      }

      Rails.logger.info params

      begin
        r = WxPay::Service.invoke_refund params

        Rails.logger.info r

        order.update_attribute(:request_refund_at, Time.now)

        refund = PaymentRefund.new(r)
        refund.save!
      rescue RestClient::RequestTimeout => e
        Rails.logger.info e

        Resque.enqueue_at(10.seconds.from_now, AchieveOrderRefundOnlinePayment, orderid)
      end
    end


  end
end