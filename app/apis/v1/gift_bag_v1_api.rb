require 'helpers/gift_bag_v1_api_helper'

=begin
礼包操作API(认领过程)
=end
class GiftBagV1API < Grape::API
  format :json

  #嵌入帮助类
  include GiftBagV1APIHelper

  resource do

    #修改状态
    before do
      status 200
    end

    desc '酒库礼包认领' do

    end
    params do
      requires :customer_id, type: String, desc: '小Cid'
      requires :gift_bag_id, type: String, desc: '礼包id'
    end
    post 'claim' do

      return GiftBagV1APIHelper.claim(current_customerUser, params[:gift_bag_id])
    end


    desc '礼包认领列表' do
      success Entities::GiftBagClaim
    end
    params do
      requires :customer_id, type: String, desc: '小Cid'
    end
    post 'claim_list' do

      present GiftBagV1APIHelper.claim_list(current_customerUser), with: Entities::GiftBagClaim
    end

    desc '小C礼包历史列表' do
      success Entities::GiftBagHis
    end
    params do
      requires :customer_id, type: String, desc: '小Cid'
    end
    post 'his_list' do

      present GiftBagV1APIHelper.his_list(current_customerUser), with: Entities::GiftBagHis
    end


    desc '小C发送礼包' do
      detail '开通酒库 {flag:{0:失败,1:成功,2:酒库未开通,3:密码错误},msg:提信息}'
    end
    params do
      requires :customer_id, type: String, desc: '小Cid'
      requires :userinfo_id, type: String, desc: '小Bid'
      requires :password, type: String, desc: '密码'
      requires :receiver_mobile, type: String, desc: '收礼人手机号'
      requires :expiry_days, type: Integer, desc: '失效天数',values:[1,2,7]
      requires :content, type: String, desc: '祝福语'
      requires :product_list, type: String, desc: '商品信息{product_id=>count},product_id:商品id,count:数量 eg:{"56582c05c2fb4e1ae1000000":2}'
    end
    post 'send' do

      return GiftBagV1APIHelper.send(current_customerUser,declared(params))
    end


    desc '礼包详细' do
      success Entities::GiftBagDetail
    end
    params do
      requires :customer_id, type: String, desc: '小Cid'
      requires :gift_bag_id, type: String, desc: '礼包id'
    end
    post 'detail' do

      data = GiftBagV1APIHelper.detail(current_customerUser,declared(params))
      return data if data.class==Hash
      present data, with: Entities::GiftBagDetail
    end


    desc '获取礼包失效列表' do

    end
    post 'get_expiry_time_list' do
      list = []
      list << {value:1,text:"一天"}
      list << {value:2,text:"两天"}
      list << {value:7,text:"一周"}
    end


    desc '同步小Ｃ失效礼包列表' do
      detail '{flag:{0:失败,1:成功},msg:提示信息,data:同步数量}'
    end
    params do

    end
    post 'syn_expiry_gift_bags' do

      return GiftBagV1APIHelper.syn_expiry_gift_bags()
    end

  end

end