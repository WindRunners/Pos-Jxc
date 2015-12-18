class CashOrder

  include Mongoid::Document
  include Mongoid::Timestamps

  after_initialize :add_time, :if => :new_record?

  field :userinfo_id,type: BSON::ObjectId
  field :order_id,type: String
  field :orderno, type: String      #订单号码

  field :paycost,type: Float, default: 0.00  #支付金额
  field :pay_state,type: Integer  #订单状态 1 支付宝 2微信支付
  field :pay_type,type: Integer  #订单类型 1 完成
  field :pay_totle,type: Float, default: 0.00
  field :pay_date,type: DateTime

  def add_time
    self.pay_date=Time.now
  end

end
