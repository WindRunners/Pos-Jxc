require 'helpers/spirit_room_v1_api_helper'
=begin
酒库API (列表)
=end
class SpiritRoomV1API < Grape::API

  format :json

  #嵌入帮助类
  include SpiritRoomV1APIHelper

  resource do

    #修改状态
    before do
      status 200
    end
    desc '开通酒库 ' do
      detail '开通酒库 {flag:{1:成功,0:失败},msg:提信息'
    end
    params do
      requires :customer_id, type: String, desc: '小Cid'
      requires :password, type: String, desc: '密码'
    end
    post 'create' do

      return SpiritRoomV1APIHelper.create(current_customerUser, params[:password])
    end

    desc '酒库商品类型列表 ' do
      detail '酒库商品类型列表 返回列表:[{mobile_category_name:类型名称,count:商品数量}] '
    end
    params do
      requires :customer_id, type: String, desc: '小Cid'
    end
    post 'category_list' do

      return SpiritRoomV1APIHelper.category_list(current_customerUser)
    end

    desc '获取酒库商品列表' do
      detail '获取酒库商品列表'
      success Entities::SpiritRoomProduct
    end
    params do
      requires :customer_id, type: String, desc: '小Cid'
    end
    post 'product_list' do

      data = SpiritRoomV1APIHelper.product_list(current_customerUser)
      return data if data.class==Hash
      present data, with: Entities::SpiritRoomProduct
    end



    desc '提酒' do
      detail '酒库中提酒 {flag:{0:失败,1:成功,2:酒库未开通,3:密码错误},msg:提信息}'
    end
    params do
      requires :userinfo_id, type: String, desc: '当前小Bid'
      requires :customer_id, type: String, desc: '小Cid'
      requires :password, type: String, desc: '密码'
      requires :product_list, type: String, desc: '商品信息{product_id=>count},product_id:商品id,count:数量 eg:{"56582c05c2fb4e1ae1000000":2}'
      requires :consignee, type: String, desc: '收货人'
      requires :address, type: String, desc: '收货地址'
      requires :mobile, type: String, desc: '收货人手机号'
      optional :longitude, type: Float, desc: '位置纬度'
      optional :latitude, type: Float, desc: '位置经度'
    end
    post 'take_product' do

      return SpiritRoomV1APIHelper.take_product(current_customerUser,declared(params))
    end

  end

end