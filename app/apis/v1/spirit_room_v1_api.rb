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
  end

end