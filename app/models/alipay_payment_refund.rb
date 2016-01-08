class AlipayPaymentRefund
  include Mongoid::Document
  include Mongoid::Timestamps

  field :sign                               #签名
  field :sign_type
  field :result_details
  field :notify_time
  field :notify_type
  field :notify_id
  field :batch_no
  field :success_num

end