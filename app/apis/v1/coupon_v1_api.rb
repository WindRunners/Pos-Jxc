class CouponV1API < Grape::API
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

  desc '获取能参与优惠券的商品列表', {
               headers: {
                   "Authentication-Token" => {
                       description: "用户Token",
                       required: true
                   }
               },
               :entity => Entities::Product
           }
  params do
  end
  get :getCouponProductsList do
    present Product.shop(current_user).where(:state_id => State.find_by(:value => "online"), :coupon_id => nil), with: Entities::Product
  end

  desc '获取指定状态的优惠券信息', {
               headers: {
                   "Authentication-Token" => {
                       description: "用户Token",
                       required: true
                   }
               },
               :entity => Entities::Coupon
           }
  params do
    requires :aasm_state, type: String, desc: '优惠券状态：noBeging:未开始, beging:正在进行, end:已结束, invalided:已失效'
  end
  get :getCouponList do
    authenticate!
    coupons = Coupon.where(:aasm_state => params[:aasm_state], :userinfo_id => @current_user.userinfo.id)
    coupons += Coupon.where(:aasm_state => "end", :userinfo_id => @current_user.userinfo.id) if "invalided" == params[:aasm_state]
    present coupons, with: Entities::Coupon
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
    requires :coupon, type: String, desc: "优惠券信息，json字符串{title:标题,quantity:数量,value:面值,limit:领取限制，每个限领张数(0是不限制),start_time:开始时间(yyyy-MM-dd HH:mm),end_time:结束时间,order_amount_way:订单限制方式:0:无限制, 1:看order_amount的值,order_amount:订单满多少可使用,order_amount_way = 1才有用,use_goods:可使用的商品0:全店通用,1:指定商品,instructions:使用说明,tag:同步为商品打标签,product_ids:[]参与优惠券的商品id数组}"
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
    requires :coupon, type: String, desc: "优惠券信息，json字符串{title:标题,quantity:数量,value:面值,limit:领取限制，每个限领张数(0是不限制),start_time:开始时间(yyyy-MM-dd HH:mm),end_time:结束时间,order_amount_way:订单限制方式:0:无限制, 1:看order_amount的值,order_amount:订单满多少可使用,order_amount_way = 1才有用,use_goods:可使用的商品0:全店通用,1:指定商品,instructions:使用说明,tag:同步为商品打标签,product_ids:[]参与优惠券的商品id数组}"
    requires :coupon_id, type: String, desc: "优惠券id"
  end
  post :updateCoupon do
    authenticate!
    coupon = Coupon.find(params[:coupon_id])
    coupon.old_coupon = coupon.clone
    if coupon.update(JSON.parse(params[:coupon]))
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
  get :invalidCoupon do
    authenticate!
    if Coupon.where(:id => params[:coupon_id]).update(:aasm_state => "invalided")
      {:success => true}
    else
      {:success => false}
    end
  end
end
