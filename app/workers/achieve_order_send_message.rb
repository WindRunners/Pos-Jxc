class AchieveOrderSendMessage
  @queue = :achieves_queue_send_message

  def self.perform(telephone)
    if :generation == order.load_workflow_state.to_sym
      ChinaSMS.use :yunpian, password: '9525738f52010b28d1b965e347945364'
      # 通用接口
      ChinaSMS.to telephone, "【享了么】尊敬的顾客，您在享了么已成功提交在线支付订单，请在1小时内完成支付，超时未支付订单会自动取消 客服热线：***-****-****"

    end
  end
end