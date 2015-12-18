class AchieveOrderRefundOnlinePayment

  @queue = :achieves_queue_refund_online_payment

  def self.perform(orderid)
    begin
      order = Ordercompleted.find(orderid)
    rescue
      order = Order.find(orderid)
    end

    if order.paymode == 2 then #微信支付

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

        refund = PaymentRefund.new(r)
        refund.save!
      rescue RestClient::RequestTimeout => e
        Rails.logger.info e

        Resque.enqueue_at(10.seconds.from_now, AchieveOrderRefundOnlinePayment, orderid)
      end
    end


  end
end