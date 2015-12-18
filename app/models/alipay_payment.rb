class AlipayPayment < Payment

  field :notify_time          #通知时间
  field :notify_type          #通知类型
  field :notify_id            #通知校验ID
  field :subject              #商品名称
  field :payment_type         #支付类型.默认值为：1（商品购买）
  field :trade_no             #支付宝交易号
  field :trade_status         #交易状态
  field :seller_id            #卖家支付宝用户号
  field :seller_email         #卖家支付宝账号
  field :buyer_id             #买家支付宝用户号
  field :buyer_email          #买家支付宝账号
  field :quantity             #购买数量
  field :price                #商品单价
  field :body                 #商品描述
  field :gmt_create           #交易创建时间
  field :gmt_payment          #交易付款时间
  field :is_total_fee_adjust  #是否调整总价
  field :use_coupon           #是否使用红包买家
  field :discount             #折扣
  field :refund_status        #退款状态
  field :gmt_refund           #退款时间
end