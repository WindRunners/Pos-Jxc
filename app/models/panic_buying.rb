require 'rufus-scheduler'
class PanicBuying
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :userinfo

  field :beginTime, type: String #开始时间
  field :endTime, type: String #结束时间
  field :state,type: Integer # 0-未开始 1-进行中 2-已结束

  field :avatar #活动图片

  def products
    @products ||= Product.shop_id(self.userinfo.id).where(:panic_buying => self)
  end
  # validates :beginTime, :endTime, :panic_quantity,:panic_price,:panic_name, presence: true


  def self.build_panics(userinfo)
    time_cron = ["00:00-08:00","08:00-12:00","12:00-16:00","16:00-20:00","20:00-24:00"]

    panic_buying = nil

    avatar = nil
    begin
      avatar = Warehouse::Promotion.first(:type => 'panic_buying').avatar
    end

    time_cron.each do |time|
      timearr = time.split("-")

      panic_buying = PanicBuying.new
      panic_buying.beginTime = timearr[0]
      panic_buying.endTime = timearr[1]
      panic_buying.userinfo = userinfo

      nowtime = Time.now.strftime('%H:%M:%S')
      if nowtime > timearr[0] && nowtime < timearr[1]
        panic_buying.state = 1
      elsif nowtime > timearr[1]
        panic_buying.state = 2
      elsif nowtime < timearr[0]
        panic_buying.state = 0
      end

      panic_buying.avatar = avatar if !avatar.nil?

      panic_buying.save!
      panic_buying.set_corn
    end

  end



  #发布活动事件
  def to_progress
    PanicBuying.where(:beginTime.gt => self.endTime).update!(:state => 0)
    PanicBuying.where(:endTime.lt => self.beginTime).update!(:state => 2)
  end



  def set_corn
    scheduler = Rufus::Scheduler.new

    beginTime = self.beginTime.to_time.strftime('%S %M %H')
    scheduler.cron "#{beginTime} * * *" do
      self.update!(:state => 1)
      self.to_progress
    end

    endTime = self.endTime.to_time.strftime('%S %M %H')
    scheduler.cron "#{endTime} * * *" do
      self.update!(:state => 2)
      self.end_panic
      self.to_progress
    end
  end

  def end_panic
    Product.shop_id(self.userinfo.id).where(:panic_buying => self).update!(:panic_buying => nil,:panic_quantity => 0,:panic_price => 0,:panic_sale_count => 0)
  end

end

