require 'rubygems'
require 'rufus-scheduler'
require 'net/http'


scheduler = Rufus::Scheduler.new

#每天凌晨0点1统计总量
#scheduler.cron '1 0 * * *' do
#  today = Time.now.to_date - 1
#  
#  map = %Q{
#    function() {
#      emit({userInfoId: this.userinfo_id, productId: this.product_id}, {quantity: this.quantity, purchasePrice: this.purchasePrice, income: this.retailPrice, profit: this.profit, count: 1})
#    }
#  }
#  reduce = %Q{
#    function(key, values) {
#      quantity = 0;
#      income = 0;
#      profit = 0;
#      order_number = 0;
#      values.forEach(function(value) {
#         quantity += value.quantity;
#         income += value.income;
#         profit += value.profit;
#         order_number += value.count;
#      });
#      return {quantity: quantity, income: income, profit: profit, order_number: order_number}
#    }
#  }
#  
#  productStatistics = Statistic.where(:retailDate => {"$gte" => today,"$lte" => today}).map_reduce(map, reduce).out(:inline => true)
#  productStatistics.each do |productStatistic|
#    begin
#      statisticTotal = StatisticTotal.find_by(:product_id => productStatistic["_id"]["productId"], :userinfo_id => productStatistic["_id"]["userInfoId"])
#    rescue
#      statisticTotal = StatisticTotal.new(:product_id => productStatistic["_id"]["productId"], :userinfo_id => productStatistic["_id"]["userInfoId"])
#    end
#    
#    statisticTotal.total_quantity += productStatistic["value"]["quantity"]
#    statisticTotal.total_income += productStatistic["value"]["income"]
#    statisticTotal.total_order_number += productStatistic["value"]["order_number"]
#    statisticTotal.total_profit += productStatistic["value"]["profit"]
#    
#    statisticTotal.save
#  end
#end

#每隔一分钟检查活动状态
scheduler.cron '*/1 * * * *' do
   @full_reductions = FullReduction.where(:end_time => {"$gte" => Time.now})
   @full_reductions += Coupon.where(:end_time => {"$gte" => Time.now}, :aasm_state => {"$not" => {"$eq" => "invalid"}})
   @full_reductions += PromotionDiscount.where(:end_time => {"$gte" => Time.now})
   @full_reductions.each do |fr|
     today = Time.now.strftime('%Y%m%d%H%M%S').to_i
     startTime = fr.start_time.strftime('%Y%m%d%H%M%S').to_i
     endTime = fr.end_time.strftime('%Y%m%d%H%M%S').to_i
     puts "today===//#{today}//===startTime==//#{startTime}//==endTime=//#{endTime}//"
     if today >= startTime && today < endTime
       puts "start======"
       fr.save if fr.start if "beging" != fr.aasm_state
     elsif today < startTime
       puts "ready======"
       fr.save if fr.ready if "noBeging" != fr.aasm_state
     else
       puts "stop======="
       fr.save if fr.stop if "end" != fr.aasm_state
     end
   end
end


#从OA获取闪屏广告
scheduler.cron '*/60 * * * *' do
#scheduler.cron '40 03 * * *' do
  url = RestConfig::OA_SERVER + 'api/v1/ads/splash_screen?type=JYD'


  headers = {}
  headers['X-Warehouse-Rest-Api-Key'] = '5604a417c3666e0b7300001a'


  response = RestClient.get(url, headers)


  json = JSON.parse(response.body)

  begin
    splash = Splash.find(json['id'])
    splash.destroy
  rescue
  end

  avatar = RestConfig::OA_SERVER + json.delete('avatar')

  splash = Splash.new(json)

  splash.avatar = avatar

  if splash.save
    Rails.logger.info "#{splash.id} has been saved."
    {success: "#{splash.id} has been saved."}
  else
    Rails.logger.info splash.errors
    error!({"message" => splash.errors}, 202)
  end

  Rails.logger.info "自动抓取闪屏广告成功"
end

#从OA获取轮播图

scheduler.cron '*/60 * * * *' do
#scheduler.cron '40 03 * * *' do

  url = RestConfig::OA_SERVER + 'api/v1/ads/carousels?type=JYD'


  headers = {}
  headers['X-Warehouse-Rest-Api-Key'] = '5604a417c3666e0b7300001a'


  response = RestClient.get(url, headers)


  array = JSON.parse(response.body)

  array.each do |json|

    begin
      carousel = Carousel.find(json['id'])
      carousel.destroy
    rescue
    end

    avatar = RestConfig::OA_SERVER + json.delete('avatar')

    carousel = Carousel.new(json)

    carousel.avatar = avatar

    if carousel.save
      Rails.logger.info "#{carousel.id} has been saved."
      {success: "#{carousel.id} has been saved."}
    else
      Rails.logger.info carousel.errors
      error!({"message" => carousel.errors}, 202)
    end
  end


  Rails.logger.info "自动抓取轮播图成功"
end


scheduler.at Time.now do
  @panic_buyings = PanicBuying.all
  @panic_buyings.each do |panic_buying|
    nowtime = Time.now.strftime('%H:%M:%S')
    if nowtime > panic_buying.beginTime && nowtime < panic_buying.endTime
      panic_buying.state = 1
    elsif nowtime > panic_buying.endTime
      panic_buying.state = 2
    elsif nowtime < panic_buying.beginTime
      panic_buying.state = 0
    end
    panic_buying.save!
    panic_buying.set_corn
  end
end
#scheduler.join
