class ShareIntegralV1API < Grape::API
  format :json

  desc '推荐有礼接口' do
    success Entities::ShareIntegral
  end
  params do
    requires :customer_id, type: String, desc: '小Cid'
    requires :userinfo_id, type: String, desc: '小Bid'
  end
  post 'share_info' do

    status 200
    now_date = Time.now
    share_integral = ShareIntegral.where({'userinfo_id' => BSON::ObjectId(params[:userinfo_id]), 'start_date' => {'$lte' => now_date}, 'end_date' => {'$gte' => now_date}, 'status' => 1}).first()

    if share_integral.present?
      share_integral['share_url'] = '/userinfos/567cabaac2fb4e05b6000011/products/568b9071af484356f3000397/desc'
      present share_integral, with: Entities::ShareIntegral
    else
      {}
    end
  end

end