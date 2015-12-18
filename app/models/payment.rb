class Payment
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :order, :foreign_key => :out_trade_no

  field :sign             #签名
  field :total_fee        #货币种类
  field :sign_type        #签名类型
end