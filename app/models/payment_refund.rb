class PaymentRefund
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :wx_payment, :foreign_key => :transaction_id #微信订单号
  belongs_to :order, :foreign_key => :out_trade_no #商户订单号

  field :result_code                        #业务结果
  field :return_code                        #返回代码
  field :return_msg                         #返回结果
  field :err_code                           #错误代码
  field :err_code_des                       #错误代码描述
  field :appid                              #微信分配的公众账号ID
  field :mch_id                             #微信支付分配的商户号
  field :device_info                        #微信支付分配的终端设备号，
  field :nonce_str                          #随机字符串
  field :sign                               #签名
  field :out_refund_no                      #商户退款单号
  field :refund_id                          #微信退款单号
  field :refund_channel                     #退款渠道
  field :refund_fee, type: Integer          #退款金额
  field :total_fee, type: Integer           #订单总金额
  field :fee_type                           #订单金额货币种类
  field :cash_fee, type: Integer            #现金支付金额
  field :cash_refund_fee, type: Integer     #现金退款金额
  field :coupon_refund_fee, type: Integer   #代金券或立减优惠退款金额
  field :coupon_refund_count, type: Integer #代金券或立减优惠使用数量
  field :coupon_refund_id                   #代金券或立减优惠ID

end