class WxPayment < Payment

  field :transaction_id   #微信支付订单号
  field :appid            #微信分配的公众账号ID
  field :device_info      #微信支付分配的终端设备号，
  field :bank_type        #付款银行
  field :cash_fee         #现金支付金额
  field :fee_type         #货币种类
  field :is_subscribe     #是否关注公众账号
  field :mch_id           #微信支付分配的商户号
  field :nonce_str        #随机字符串
  field :openid           #用户在商户appid下的唯一标识
  field :result_code      #业务结果
  field :return_code      #返回状态码
  field :time_end         #支付完成时间
  field :trade_type       #交易类型
end