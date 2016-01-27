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
    share_integral = ShareIntegral.where({'start_date' => {'$lte' => now_date}, 'end_date' => {'$gte' => now_date}, 'status' => 1}).first()
    if share_integral.present?
      share_integral['share_url'] = "/share_integrals/share?shared_customer_id=#{params[:customer_id]}"
    else
      share_integral = ShareIntegral.new()
      share_integral.shared_give_integral = 0
      share_integral.register_give_integral = 0
      share_integral.title = "推荐有礼，敬请期待！！"
    end
    present share_integral, with: Entities::ShareIntegral
  end

end