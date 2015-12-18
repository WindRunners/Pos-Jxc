class Cash
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :userinfo

  after_initialize :set_cash_no, :if => :new_record?

  field :userinfo_id,type: BSON::ObjectId
  field :cash_no,type: String
  field :cash_rno,type: String
  field :cash,type: Integer   #取现金额
  field :cash_state,type: Integer ,default: 1 #取现状态
  field :cash_req_date, type: DateTime #取现申请时间
  field :cash_back_date, type: DateTime #取现申请返回时间
  field :cash_back_info, type: String   #oa回馈信息
  field :cash_name,type: String #
  field :cash_email,type: String #
  field :pay_name,type: String
  field :pay_email,type: String

  # field :cash_totle,type: Float, default: 0.00 #合计

  def cash_state_to_s
    if self.cash_state == 1
      p '请求中...'
    elsif self.cash_state == 2
      p '您的申请已成功发送，我们将于24小时内对您的申请作出取现'
    elsif self.cash_state == 3
      p '操作不成功'
      cash_state=0
    elsif self.cash_state == 4
      p '余额转积分'
    elsif self.cash_state == 9
      p '取现成功'
    end
  end

  def data_show
    if self.cash_state ==1
      p  self.cash_req_date.strftime('%Y-%m-%d %H:%M:%S').to_s
    elsif self.cash_state ==2 || self.cash_state==4
      self.cash_req_date.strftime('%Y-%m-%d %H:%M:%S').to_s
    elsif self.cash_state ==9
      self.cash_back_date.strftime('%Y-%m-%d %H:%M:%S').to_s
    end
  end

  # def cash_totle
  #   totle=0
  #   if self.cash_state ==9
  #     totle+=self.cash_totle
  #   end
  #   return totle
  # end

  def set_cash_no
    time = Time.now
    self.cash_no = time.strftime("%Y%m%d%S") + time.usec.to_s
  end

end
