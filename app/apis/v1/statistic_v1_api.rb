class StatisticV1API < Grape::API
  format :json
  
  helpers do
    def ahoy
      @ahoy ||= Ahoy::Tracker.new
    end
    
    def current_user
      token = headers['Authentication-Token']
      @current_user = User.find_by(authentication_token:token)
    rescue
      error!('401 Unauthorized', 401)

    end

    def authenticate!

      error!('401 Unauthorized', 401) unless current_user
    end

    def customsDateFormat(dateObj)
      dateObj.strftime("%Y-%m-%d")
    end
  end
  
  desc '根据年，季，月，日获取当前维度数据统计', {
                   headers: {
                       "Authentication-Token" => {
                           description: "用户Token",
                           required: true
                       }
                   },
                   :entity => Entities::Statistic
               }
  params do
    requires :dimension, type: String, values: ["Y", "S", "M", "W", "D"], desc: '维度,Y:年, S:季, M:月, W:周, D:天'
  end
  get :statisticByDimension do
    authenticate!
    today = Time.now.to_date
    seasons = Hash.new  #月份与当前季度开始月份对应
    12.times do |n|
      seasons[(n + 1).to_s] = (n / 3).to_i * 3 + 1
    end
    Rails.logger.info "123123---///#{seasons}"
    map = %Q{
      function() {
        emit(this.userinfo.id, {totalPrice: this.paycost, profit: this.profit, count: 1})
      }
    }
    mapStatistic = %Q{
      function() {
        emit(this.userinfo_id, {totalPrice: this.total_price, profit: this.profit, count: 1})
      }
    }
    reduce = %Q{
      function(key, values) {
        profit = 0.0;
        income = 0.0;
        count = 0;
        incomes = []
        profits = []
        values.forEach(function(value) {
           income += value.totalPrice;
           profit += value.profit;
           count += value.count;
        });
        return {profit: profit, income: income, count: count}
      }
    }
    startTime = today.to_time  #当天零点
    endTime = Time.now 
    endDate = (today - 1).strftime("%Y-%m-%d")
    resultStatistic = {:profit => 0.0, :income => 0.0, :visitorCount => 0, :watingOrderCount => 0, :orderCount => 0}
    case params[:dimension]
    when "W" then
      startDate = (today - today.wday + 1).strftime("%Y-%m-%d")
    when "M" then
      startDate = "#{today.year}-#{today.month}-01"
    when "S" then
      startDate = "#{today.year}-#{seasons[today.month.to_s]}-01"
    when "Y" then
      startDate = "#{today.year}-01-01"
    end
    Rails.logger.info "startDate====#{startDate}--=====endDate==#{endDate}----===startTime=#{startTime}---===endTime=#{endTime}"
    if startDate.present?
      statistics = OrderStatistic.where({:complete_date => {"$gte" => startDate, "$lte" => endDate}, :userinfo_id => @current_user.userinfo.id})
      statistics.each do |s|
        resultStatistic[:profit] += s.profit
        resultStatistic[:income] += s.total_price
        resultStatistic[:orderCount] += s.profit
      end
    end
    statistics = Ordercompleted.where(:userinfo_id => @current_user.userinfo.id, :workflow_state => "completed", :updated_at => {"$gte" => startTime, "$lte" => endTime})
    statistics.each do |s|
      resultStatistic[:profit] += s.profit
      resultStatistic[:income] += s.paycost
      resultStatistic[:orderCount] += s.profit
    end
    watingOrderCount = Order.where(:userinfo_id => @current_user.userinfo.id, :workflow_state => "paid").count
    resultStatistic[:watingOrderCount] = watingOrderCount
    resultStatistic[:visitorCount] = resultStatistic[:orderCount] * 4 + rand(500).to_i
    resultStatistic[:profit] = format("%.2f", resultStatistic[:profit]).to_f
    resultStatistic[:income] = format("%.2f", resultStatistic[:income]).to_f
    resultStatistic
  end
  
  desc '根据开始跟结束日期获取数据统计', {
                   headers: {
                       "Authentication-Token" => {
                           description: "用户Token",
                           required: true
                       }
                   },
                   :entity => Entities::Statistic
               }
  params do
    requires :startDate, type: String, desc: '开始日期,格式:YYYY-MM-DD'
    requires :endDate, type: String, desc: '结束日期,格式:YYYY-MM-DD'
  end
  get :statisticByDate do
    authenticate!
    map = %Q{
      function() {
        emit(this.userinfo_id, {totalPrice: this.total_price, profit: this.profit, count: 1})
      }
    }
    reduce = %Q{
      function(key, values) {
        profit = 0;
        income = 0;
        count = 0;
        values.forEach(function(value) {
           income += value.totalPrice;
           profit += value.profit;
           count += value.count;
        });
        return {profit: profit, income: income, count: count}
      }
    }
    resultStatistic = {:profit => 0.0, :income => 0.0, :visitorCount => 0, :orderCount => 0}
    statistics = OrderStatistic.where({:complete_date => {"$gte" => params[:startDate], "$lte" => params[:endDate]}, :userinfo_id => @current_user.userinfo.id})
    statistics.each do |s|
        resultStatistic[:profit] += s.profit
        resultStatistic[:income] += s.total_price
        resultStatistic[:orderCount] += s.profit
    end
    resultStatistic[:visitorCount] = resultStatistic[:orderCount] * 4 + rand(500).to_i
    resultStatistic[:profit] = format("%.2f", resultStatistic[:profit]).to_f
    resultStatistic[:income] = format("%.2f", resultStatistic[:income]).to_f
    resultStatistic
  end

  desc '根据相应维度获取下级维度数据统计', {
                   headers: {
                       "Authentication-Token" => {
                           description: "用户Token",
                           required: true
                       }
                   },
                   :entity => Entities::Statistic
               }
  params do
    requires :dimension, type: String, values: ["M", "W", "Q"], desc: '维度: M:月, W:周, Q:季'
  end
  get :getSubDimStatisticByDimension do
    authenticate!
    today = Time.now.to_date
    mapStatistic = %Q{
      function() {
        emit(this.complete_date, {totalPrice: this.total_price, profit: this.profit, count: 1})
      }
    }
    map = %Q{
      function() {
        emit(this.userinfo_id, {totalPrice: this.total_price, profit: this.profit, count: 1})
      }
    }
    reduce = %Q{
      function(key, values) {
        profit = 0;
        income = 0;
        count = 0;
        values.forEach(function(value) {
           income += value.totalPrice;
           profit += value.profit;
           count += value.count;
        });
        return {profit: profit, income: income, count: count}
      }
    }
    dateRange = Array.new
    endDate = today - 1
    resultStatistic = Array.new
    defaultStatistic = {:profit => 0.0, :income => 0.0, :visitorCount => 0, :orderCount => 0}
    case params[:dimension]
    when "W" then
      for i in 1..7
        startDate = today - i.day
        dateRange << [startDate, startDate]
      end
      dateRange = dateRange.reverse
    when "M" then
      startDate = endDate - 30.day
      while startDate < endDate
        dateRange << [startDate, startDate + 4.day]
        startDate += 5.day
      end
      dateRange << [startDate - 5.day, startDate - 5.day + ((endDate - startDate).to_i - 1).day] if 5 == dateRange.size
      dateRange << [endDate, endDate]
    when "Q" then
      startDate = endDate - 90.day
      while startDate < endDate
        dateRange << [startDate, startDate + 14.day]
        startDate += 15.day
      end
      dateRange << [startDate - 15.day, startDate - 15.day + ((endDate - startDate).to_i - 1).day] if 5 == dateRange.size
      dateRange << [endDate, endDate]
    end
    dateRange.each do |dr|
      Rails.logger.info "startDate==#{customsDateFormat(dr[0])}===endDate=#{customsDateFormat(dr[1])}"
      statisticsCount = OrderStatistic.where({:complete_date => {"$gte" => customsDateFormat(dr[0]), "$lte" => customsDateFormat(dr[1])}, :userinfo_id => @current_user.userinfo.id}).count
      if 0 < statisticsCount
        statistics = OrderStatistic.where({:complete_date => {"$gte" => customsDateFormat(dr[0]), "$lte" => customsDateFormat(dr[1])}, :userinfo_id => @current_user.userinfo.id}).map_reduce(map, reduce).out(:inline => true)
        resultStatistic += statistics.collect {|s| {"#{customsDateFormat(dr[0])}-#{customsDateFormat(dr[1])}" => s["value"]}}
      else
        resultStatistic << {"#{customsDateFormat(dr[0])}-#{customsDateFormat(dr[1])}" => defaultStatistic}
      end
    end
    resultStatistic
  end
end
