require 'grape'
require 'helpers/delivery_order_v1_api_helper'
=begin

 配送端订单接口API,包括(接单列表,接单,接单历史)

=end
class DeliveryOrderV1API < Grape::API

  format :json

  use ApiLogger
  
  #嵌入帮助类
  include DeliveryOrderV1APIHelper


  #需要身份验证的接口
  resource do

    #路由之前身份认证
    before do
      authenticate_deliveryUser
      status 200 #修改post默认返回状态
    end


    desc '接单列表' do
      success Entities::DeliveryOrderTake
    end
    params do
      requires :token, type: String, desc: '身份认证token'
      optional :longitude, type: Float, desc: '位置经度'
      optional :latitude, type: Float, desc: '位置纬度'
      optional :page, type: Integer, desc: '页码', default: 1
    end
    post 'take_order_list' do

      present DeliveryOrderV1APIHelper.take_order_list(current_deliveryUser,declared(params)), with: Entities::DeliveryOrderTake
    end


    desc '接单' do
      detail '返回结果:{flag:(1:成功,0:失败),msg:提示信息}'
    end
    params do
      requires :token, type: String, desc: '身份认证token'
      requires :order_id, type: String, desc: '订单id'
    end
    post 'take_order' do
      DeliveryOrderV1APIHelper.take_order(current_deliveryUser,declared(params))
    end

    desc '接货' do
      detail '图片上传参数为:product_img[] 返回结果:{flag:(1:成功,0:失败),msg:提示信息}'
    end
    params do
      requires :token, type: String, desc: '身份认证token'
      requires :order_id, type: String, desc: '订单id'
      # optional :product_img, type: File, desc: '订单id'
    end
    post 'take_product' do

      # p "#参数信息为:#{declared(params)}"
      Rails.logger.info  "接货图片参数信息为product_img:#{params[:product_img]}"

      order_id = params[:order_id] #获取订单列表
      order = Order.where({'_id'=>order_id}).first
      return {msg: '当前订单不存在!', flag: 0} if !order.present?
      return {msg: '订单状态不合法!', flag: 0} if order.current_state.name.to_s!='take'
      order['workflow_event'] = "take_product" #方便订单判断是否为接货状态
      order.take_product! #接货
      Rails.logger.info "配送员接货完毕"

      #更改订单状态
      order_track = OrderTrack.new()
      order_track.order = order
      product_img_array = params[:product_img] #获取商品图片
      img_urls = []
      if product_img_array.present?
        product_img_array.each_with_index do |item, index|
          time = Time.new
          dir_path = "upload/image/order_strack/#{time.year}/#{time.month}/#{time.day}/#{SecureRandom.uuid}/"
          img_urls << upload_file(item,dir_path) #上传文件
          Rails.logger.info "上传文件成功路径为#{img_urls}"
        end
      end
      order_track['img_urls'] = img_urls
      order_track.save!
      {msg: '接货成功!', flag: 1}
    end

    desc '配送完成' do
      detail '返回结果:{flag:(1:成功,0:失败),msg:提示信息}'
    end
    params do
      requires :token, type: String, desc: '身份认证token'
      requires :order_id, type: String, desc: '订单id'
    end
    post 'delivery_finished' do

      DeliveryOrderV1APIHelper.delivery_finished(current_deliveryUser,declared(params))
    end

    desc '订单详情' do
      success Entities::DeliveryOrderDetail
    end
    params do
      requires :token, type: String, desc: '身份认证token'
      requires :order_id, type: String, desc: '订单id'
      optional :longitude, type: Float, desc: '位置经度'
      optional :latitude, type: Float, desc: '位置纬度'
    end
    post 'order_detail' do

      present DeliveryOrderV1APIHelper.order_detail(current_deliveryUser,declared(params)), with: Entities::DeliveryOrderDetail
    end


    desc '我的订单列表' do
      success Entities::DeliveryOrderHis
    end
    params do
      requires :token, type: String, desc: '身份认证token'
      optional :page, type: Integer, desc: '页码'
      optional :longitude, type: Float, desc: '位置经度'
      optional :latitude, type: Float, desc: '位置纬度'
      optional :page, type: Integer, desc: '页码', default: 1
    end
    post 'my_order_list' do

      present DeliveryOrderV1APIHelper.my_order_list(current_deliveryUser,declared(params)), with: Entities::DeliveryOrderHis
    end


    desc '我的订单历史列表' do
      success Entities::DeliveryOrderHis
    end
    params do
      requires :token, type: String, desc: '身份认证token'
      requires :page, type: Integer, desc: '页码', default: 1
    end
    post 'my_order_hi_list' do

      present DeliveryOrderV1APIHelper.my_order_hi_list(current_deliveryUser,declared(params)), with: Entities::DeliveryOrderHis
    end



    desc '订单列表行数（待接单、我的订单、历史订单）' do
      detail '返回结果行数'
    end
    params do
      requires :token, type: String, desc: '身份认证token'
      optional :flag, type: Integer, desc: '标识、0：接单列表、1：我的订单、2：历史订单', default: 0,values:[0,1,2]
    end
    post 'order_rows' do

      return DeliveryOrderV1APIHelper.order_rows(current_deliveryUser,declared(params))
    end

  end


end