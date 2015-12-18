class FullReductionV1API < Grape::API
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
  end

  desc '获取所有优惠券信息' do
    success Entities::Coupon
  end
  params do
    requires :id, type: String, desc: '小B的ID'
  end
  get :getCouponList do
      return {:success => false, :info => "小B不信息不存在"} if 0 == Userinfo.where(:id => params[:id]).count
      present Coupon.where(:aasm_state => "beging", :userinfo_id => params[:id]), with: Entities::Coupon
  end
  
  desc '创建优惠券', {
               headers: {
                   "Authentication-Token" => {
                       description: "用户Token",
                       required: true
                   }
               },
               :entity => Entities::Status
           }
  params do
    requires :coupon, type: String, desc: "优惠券信息，json字符串{title:标题,quantity:数量,value:面值,limit:领取限制，每个限领,start_time:开始时间(yyyy-MM-dd HH:mm),end_time:结束时间,order_amount_way:订单限制方式:0:无限制, 1:看order_amount的值,order_amount:订单满多少可使用,order_amount_way = 1才有用,use_goods:可使用的商品0:全店通用,1:指定商品,instructions:使用说明,tag:同步为商品打标签,product_ids:[]参与优惠券的商品数组}"
  end
  post :createCoupon do
    authenticate!
    coupon = Coupon.new(JSON.parse(params[:coupon]))
    coupon.userinfo = @current_user.userinfo
    if coupon.save
      {:success => true}
    else
      {:success => false}
    end
  end

  desc '修改优惠券信息', {
               headers: {
                   "Authentication-Token" => {
                       description: "用户Token",
                       required: true
                   }
               },
               :entity => Entities::Status
           }
  params do
    requires :coupon, type: String, desc: "优惠券信息，json字符串{title:标题,quantity:数量,value:面值,limit:领取限制，每个限领,start_time:开始时间(yyyy-MM-dd HH:mm),end_time:结束时间,order_amount_way:订单限制方式:0:无限制, 1:看order_amount的值,order_amount:订单满多少可使用,order_amount_way = 1才有用,use_goods:可使用的商品0:全店通用,1:指定商品,instructions:使用说明,tag:同步为商品打标签,product_ids:[]参与优惠券的商品数组}"
    requires :coupon_id, type: String, desc: "优惠券id"
  end
  post :createCoupon do
    authenticate!
    if Coupon.where(:id => params[:coupon_id]).update(JSON.parse(params[:coupon]))
      {:success => true}
    else
      {:success => false}
    end
  end

  desc '失效优惠券', {
               headers: {
                   "Authentication-Token" => {
                       description: "用户Token",
                       required: true
                   }
               },
               :entity => Entities::Status
           }
  params do
    requires :coupon_id, type: String, desc: "优惠券id"
  end
  post :createCoupon do
    authenticate!
    if Coupon.where(:id => params[:coupon_id]).update(:aasm_state => "invalided")
      {:success => true}
    else
      {:success => false}
    end
  end

  desc '获取满减送，及买赠活动' do
    success Entities::FullReduction
  end
  params do
    requires :id, type: String, desc: '小B的ID'
  end
  get :getFullReductionActivities do
    return {:success => false, :info => "小B不信息不存在"} if 0 == Userinfo.where(:id => params[:id]).count
    present FullReduction.where(:aasm_state => "beging", :userinfo_id => params[:id]), with: Entities::FullReduction
  end
end
