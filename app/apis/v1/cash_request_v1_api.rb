require 'grape'
class CashRequestV1API < Grape::API
  format :json


  desc '小b的余额'
  params do
    requires 'userinfo_id',type:String,desc: '小b的id'
  end
  get :balance do
    array=[]
      begin
      @cashes = Cash.all
      @cashOrders=CashOrder.all

      @pay_o=0
      @pay_q=0
      @cash_totle=0
      @cashOrders.each do |cashOrder|
        if cashOrder.userinfo_id.to_s==params[:userinfo_id] #完成订单
          @pay_o=cashOrder.paycost + @pay_o
        else
          @pay_o=0
        end
      end
      @cash_totle=0
      @cash_y=0
      @cashing_totle=0
      @cashes.each do |cash|
        if cash.cash_state == 2 && cash.userinfo_id.to_s==params[:userinfo_id]
          @cash_totle=cash.cash + @cash_totle
        elsif cash.cash_state == 1 && cash.userinfo_id.to_s==params[:userinfo_id]
          @cashing_totle = cash.cash + @cashing_totle
        elsif cash.cash_state == 4 && cash.userinfo_id.to_s==params[:userinfo_id]
          @cash_y= cash.cash + @cash_y
        end
      end
      @pay_totle=@pay_o-(@cash_totle+@cashing_totle+@cash_y)

      array << {banlance:"#{@pay_totle.to_i}"}
      rescue
        array << {banlance:"0"}
      end

    return array
  end

  desc '小B现金申请'
  params do
    requires :userinfo_id,type:String,desc: '小b的id'
    requires :cash,type: String,desc: '提现金额'
  end
  get 'cash_request' do
    array=[]
    @cashes = Cash.all
    @cashOrders=CashOrder.all
    @pay_o=0
    @pay_q=0
    @cash_totle=0
    @cashOrders.each do |cashOrder|
      if cashOrder.userinfo_id.to_s==params[:userinfo_id] #完成订单
        @pay_o=cashOrder.paycost + @pay_o
      else
        @pay_o=0
      end
    end
    @cash_totle=0
    @cash_y=0
    @cashing_totle=0
    @cashes.each do |cash|
      if cash.cash_state == 2 && cash.userinfo_id.to_s==params[:userinfo_id]
        @cash_totle=cash.cash + @cash_totle
      elsif cash.cash_state == 1 && cash.userinfo_id.to_s==params[:userinfo_id]
        @cashing_totle = cash.cash + @cashing_totle
      elsif cash.cash_state == 4 && cash.userinfo_id.to_s==params[:userinfo_id]
        @cash_y= cash.cash + @cash_y
      end
    end
    @pay_totle=@pay_o-(@cash_totle+@cashing_totle+@cash_y)

       if  (@pay_totle-params[:cash].to_i)<0
         array << {messages:"余额不足，请求失败",state:"0"}
       else
         cash=Cash.new
         cash.cash_req_date=Time.now
         cash.userinfo_id =params[:userinfo_id]
         cash.cash_state=1
         cash.cash=params[:cash]
         if params[:cash].blank?
           array << {messages:"非法金额，请求失败",state:"0"}
         else
           cash.save
           p_totle=@pay_totle-params[:cash].to_i
           array << {messages:"请求成功",state:"1",pay_totle:"#{p_totle.to_i}"}
         end

       end
  end

  desc '获取小b的全部订单'
  params do
    requires :userinfo_id,type: String,desc: '小b的id'
  end
  get 'userinfo_orders'  do
    array=[]
    order_totle=0
    pay_way=''
    begin
      @cashOrders=CashOrder.where(userinfo_id: params[:userinfo_id])
      @cashOrders.each do |c|
        if c.pay_state==1
          pay_way='支付宝'
        elsif c.pay_state==2
          pay_way='微信支付'
        end
        order_totle+=c.paycost
        array << {orderno:"#{c.orderno}",paycost: "#{c.paycost}",pay_state:"#{pay_way}",pay_date:"#{c.pay_date.strftime('%Y-%m-%d %H:%M:%S').to_s}",order_totle:order_totle}
      end
      return array
    rescue
      array << {messages:"还没有订单",state:"0"}
    end
  end

  desc '获取小b支付明细,提现状态cash_state  1 请求 2 Oa审阅 9提现到账'
  params do
    requires :userinfo_id,type: String,desc: '小b的id'
  end
  get 'userinfo_payinfo' do
    begin
      array=[]
      @cashes=Cash.all
      @cashes.each do |c|
        if c.userinfo_id.to_s==params[:userinfo_id]
        array << {cash_no:"#{c.cash_no}",cash:"#{c.cash}",cash_state:"#{c.cash_state}",cash_req_date:"#{c.cash_req_date.strftime('%Y-%m-%d %H:%M:%S').to_s}",cash_back_date:"#{c.cash_back_date.strftime('%Y-%m-%d %H:%M:%S').to_s}",}
        end
      end
      return array
    rescue
      array << {messages:"没有支出信息",state:"0"}
    end

  end

end