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


scheduler.cron '40 03 * * *' do
  splashes = Splash.splashCache
  if SpalashScreenAsset.all.present?
    @spalashScreenAssets=SpalashScreenAsset.all
    if  File::directory?( "public/upload/image/splash_screen/splash_screen_assets/" )
      p '-=-='
      Net::HTTP.start("10.99.99.206") { |http|
        resp = http.get("/#{splashes[0].splash_screen_img}")
        p splashes[0].splash_screen_img
        open("public/#{splashes[0].splash_screen_img.split(".")[0]+".png"}", "wb") { |file|
          file.write(resp.body) }
      }
      @spalashScreenAssets[0].update("img_path"=>splashes[0].splash_screen_img)
      @spalashScreenAssets[0].update("seconds"=>splashes[0].stop_seconds)
      p '-=-='
    else
      FileUtils.makedirs("public/upload/image/splash_screen/splash_screen_assets/")
      Net::HTTP.start("10.99.99.206") { |http|
        resp = http.get("/#{splashes[0].splash_screen_img}")
        open("public/#{splashes[0].splash_screen_img.split(".")[0]+".png"}", "wb") { |file|
          file.write(resp.body) }
      }
      @spalashScreenAssets[0].update("img_path"=>splashes[0].splash_screen_img)
      @spalashScreenAssets[0].update("seconds"=>splashes[0].stop_seconds)
    end
  else
    @spalashScreenAsset=SpalashScreenAsset.new
    if  File::directory?( "public/upload/image/splash_screen/splash_screen_assets/" )
      p '-=-='
      Net::HTTP.start("10.99.99.206") { |http|
        resp = http.get("/#{splashes[0].splash_screen_img}")
        p splashes[0].splash_screen_img
        open("public/#{splashes[0].splash_screen_img.split(".")[0]+".png"}", "wb") { |file|
          file.write(resp.body) }
      }
      @spalashScreenAsset.update("img_path"=>splashes[0].splash_screen_img)
      @spalashScreenAsset.update("seconds"=>splashes[0].stop_seconds)
      p '-=-='
    else
      FileUtils.makedirs("public/upload/image/splash_screen/splash_screen_assets/")
      Net::HTTP.start("10.99.99.206") { |http|
        resp = http.get("/#{splashes[0].splash_screen_img}")
        open("public/#{splashes[0].splash_screen_img.split(".")[0]+".png"}", "wb") { |file|
          file.write(resp.body) }
      }
      @spalashScreenAsset.update("img_path"=>splashes[0].splash_screen_img)
      @spalashScreenAsset.update("seconds"=>splashes[0].stop_seconds)
    end
  end
  puts "自动抓取抓取成功"
end

scheduler.cron '30 03 * * *' do
    carous = Carou.carouCache
    begin
      carouselAssets=CarouselAsset.all
      if carous[0].present?
        Net::HTTP.start("10.99.99.206") { |http|
          resp = http.get("/#{carous[0].img1}")
          open("public/#{carous[0].img1.split(".")[0]+".png"}", "wb") { |file|
            file.write(resp.body)
          }
        }
        carouselAssets[0].update("img1_path"=>carous[0].img1)

        Net::HTTP.start("10.99.99.206") { |http|
          resp = http.get("/#{carous[0].img2}")
          open("public/#{carous[0].img2.split(".")[0]+".png"}", "wb") { |file|
            file.write(resp.body)
          }
        }
        carouselAssets.update("img2_path"=>carous[0].img2)
      end
    rescue
      carouselAsset=CarouselAsset.new
      if File:: directory?("public/upload/image/carousel/carousel_assets/")
        if carous[0].present?
          Net::HTTP.start("10.99.99.206") { |http|
            resp = http.get("/#{carous[0].img1}")
            open("public/#{carous[0].img1.split(".")[0]+".png"}", "wb") { |file|
              file.write(resp.body)
            }
          }
          carouselAsset.update("img1_path"=>carous[0].img1)

          Net::HTTP.start("10.99.99.206") { |http|
            resp = http.get("/#{carous[0].img2}")
            open("public/#{carous[0].img2.split(".")[0]+".png"}", "wb") { |file|
              file.write(resp.body)
            }
          }
          carouselAsset.update("img2_path"=>carous[0].img2)
        end
      else
        FileUtils.makedirs("public/upload/image/carousel/carousel_assets/")
        if carous[0].present?
          Net::HTTP.start("10.99.99.206") { |http|
            resp = http.get("/#{carous[0].img1}")
            open("public/#{carous[0].img1.split(".")[0]+".png"}", "wb") { |file|
              file.write(resp.body)
            }
          }
          carouselAsset.update("img1_path"=>carous[0].img1)
          Net::HTTP.start("10.99.99.206") { |http|
            resp = http.get("/#{carous[0].img2}")
            open("public/#{carous[0].img2.split(".")[0]+".png"}", "wb") { |file|
              file.write(resp.body)
            }
          }
          carouselAssets.update("img2_path"=>carous[0].img2)
        end
      end
    end
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
