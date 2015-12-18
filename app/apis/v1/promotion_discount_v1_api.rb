class PromotionDiscountV1API < Grape::API
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

  desc '获取所有促销打折信息', {
               headers: {
                   "Authentication-Token" => {
                       description: "用户Token",
                       required: true
                   }
               },
               :entity => Entities::PromotionDiscount
           }
  params do
    requires :type, type: String, desc: '活动类型：0:打折,1:促销'
  end
  get :getPromotionDiscountList do
      authenticate!
      promotionDiscounts = PromotionDiscount.where(:type => params[:type], :userinfo_id => @current_user.userinfo.id)
  end
  
  desc '创建促销打折', {
               headers: {
                   "Authentication-Token" => {
                       description: "用户Token",
                       required: true
                   }
               },
               :entity => Entities::Status
           }
  params do
    requires :promotion_discount, type: String, desc: "促销打折信息，json字符串{title:标题,discount:折扣(75:表示75折),type:0:打折，1:促销,start_time:开始时间(yyyy-MM-dd HH:mm),end_time:结束时间,use_goods: #可使用的商品0:全店通用,1:指定商品,tag:为商品几天就打标签,participate_product_ids:打折格式是品id数组, 促销格式{product_id: 商品id, product_name: 商品名称, price: 促销价格}}"
  end
  post :createPromotionDiscount do
    authenticate!
    promotion_discount = PromotionDiscount.new(JSON.parse(params[:promotion_discount]))
    promotion_discount.userinfo = @current_user.userinfo
    if promotion_discount.save
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
    requires :promotion_discount, type: String, desc: "促销打折信息，json字符串{title:标题,discount:折扣(75:表示75折),type:0:打折，1:促销,start_time:开始时间(yyyy-MM-dd HH:mm),end_time:结束时间,use_goods: #可使用的商品0:全店通用,1:指定商品,tag:为商品几天就打标签,participate_product_ids:打折格式是品id数组, 促销格式{product_id: 商品id, product_name: 商品名称, price: 促销价格}}"
    requires :promotion_discount_id, type: String, desc: "促销打折活动id"
  end
  post :updatePromotionDiscount do
    authenticate!
    if promotion_discount.where(:id => params[:promotion_discount_id]).update(JSON.parse(params[:promotion_discount]))
      {:success => true}
    else
      {:success => false}
    end
  end

  desc '删除促销打折活动', {
               headers: {
                   "Authentication-Token" => {
                       description: "用户Token",
                       required: true
                   }
               },
               :entity => Entities::Status
           }
  params do
    requires :promotion_discount_id, type: String, desc: "促销打折活动id"
  end
  get :destroyPromotionDiscount do
    authenticate!
    if PromotionDiscount.where(:id => params[:promotion_discount_id]).destroy
      {:success => true}
    else
      {:success => false}
    end
  end
end
