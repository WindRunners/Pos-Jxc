class ShareIntegralRecord
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  field :shared_customer_id, type: String
  field :register_customer_id, type: String
  field :is_confirm, type: Integer, default: 0
  field :source, type: String


  belongs_to :share_integral
  belongs_to :product_ticket



  after_save do

    if self.is_confirm == 1 && self['share_integral'].present? #登录回执记录积分

      share_integral = self.share_integral

      #分享者积分记录
      share_interalLog = IntegralLog.new({'customer_id' => self.shared_customer_id, 'quantity' => share_integral.shared_give_integral, 'memo' => '推荐有礼赠送积分'})
      share_interalLog.save

      #注册者积分记录
      register_interalLog = IntegralLog.new({'customer_id' => self.register_customer_id, 'quantity' => share_integral.register_give_integral, 'memo' => '新用户注册赠送积分'})
      register_interalLog.save
    end
  end

  def is_confirm_str

    if self.is_confirm ==0
      p "未确认"

    else
      p "已确认"
    end

  end


end
