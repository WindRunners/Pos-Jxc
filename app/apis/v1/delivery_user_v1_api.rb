require 'grape'
require 'helpers/delivery_user_v1_api_helper'
require 'helpers/regex_v1_api_helper'
=begin

 配送员借口API,包括(注册,登陆,修改)

=end
class DeliveryUserV1API < Grape::API

  format :json

  use ApiLogger

  helpers do

    def ahoy
      @ahoy ||= Ahoy::Tracker.new
    end

  end

  #嵌入帮助类
  include DeliveryUserV1APIHelper
  include RegexV1APIHelper

  desc '配送员注册' do
    success Entities::DeliveryUser
  end
  params do
    requires :mobile, type: String, desc: '手机号'
    requires :real_name, type: String, desc: '真实名'
    requires :verifycode, type: String, desc: '验证码'
    optional :longitude, type: Float, desc: '位置纬度'
    optional :latitude, type: Float, desc: '位置经度'
    optional :position, type: String, desc: '位置描述' , default: 'location failure'
    optional :province, type: String, desc: '定位所在省' , default: 'location failure'
    optional :city,type: String, desc: '定位所在市区' , default: 'location failure'
    optional :district,type: String, desc: '定位所在县区' , default: 'location failure'
  end
  post 'register' do

    status 200 #修改post默认返回状态

    mobile = params[:mobile]
    verifycode = params[:verifycode]
    real_name = params[:real_name]
    longitude = params[:longitude]
    latitude = params[:latitude]
    position = params[:position]
    province = params[:province]
    city = params[:city]
    district = params[:district]

    return {msg: '手机号不合法!', flag: 0} if !RegexV1APIHelper.mobile(mobile)
    return {msg: '验证码不合法', flag: 0} if !RegexV1APIHelper.verifycode(verifycode)


    userinfo = Userinfo.where({province: province, city: city, district: district}).first #按县区查询运营商
    userinfo = Userinfo.where({province: province, city: city}).first if !userinfo.present? #按市区查询运营商

    deliveryUser =DeliveryUser.new(mobile: mobile, real_name: real_name, longitude: longitude, latitude: latitude, position: position)
    deliveryUser['userinfo_id'] = userinfo.id if userinfo.present?

    data = DeliveryUserV1APIHelper.register(deliveryUser, verifycode)

    if (data.class == DeliveryUser)
      present data, with: Entities::DeliveryUser
    else
      return data
    end
  end


  desc '配送员登陆' do
    success Entities::DeliveryUser
  end
  params do
    requires :mobile, type: String, desc: '手机号'
    requires :verifycode, type: String, desc: '手机验证码'
    requires :channel_type, type: String, desc: '手机类型(ANDROID,IOS)'
    requires :channel_id, type: String, desc: 'channel_id'
  end
  post 'login' do

    mobile = params[:mobile]
    verifycode = params[:verifycode]

    channel = params[:channel_type] + "|" + params[:channel_id]

    return {msg: '手机号不合法!', flag: 0} if !RegexV1APIHelper.mobile(mobile)
    return {msg: '验证码不合法', flag: 0} if !RegexV1APIHelper.verifycode(verifycode)

    status 200 #修改post默认返回状态
    data = DeliveryUserV1APIHelper.login(mobile,verifycode, channel)

    if (data.class == DeliveryUser)
      present data, with: Entities::DeliveryUser
    else
      return data
    end
  end

  desc '获取配送员登录验证码'
  params do
    requires :mobile, type: String, desc: '手机号'
  end
  post 'get_login_verifycode' do

    mobile = params[:mobile]
    return  {msg: '手机号不合法!',flag:0} if !RegexV1APIHelper.mobile(mobile)

    status 200 #修改post默认返回状态
    DeliveryUserV1APIHelper.get_login_verifycode(mobile)
  end


  desc '获取配送员注册验证吗'
  params do
    requires :mobile, type: String, desc: '手机号'
  end
  post 'get_register_verifycode' do

    mobile = params[:mobile]
    return {msg: '手机号不合法!', flag: 0} if !RegexV1APIHelper.mobile(mobile)

    status 200 #修改post默认返回状态
    DeliveryUserV1APIHelper.get_register_verifycode(mobile)
  end


  desc '配送员删除'
  params do
    requires :mobile, type: String, desc: '手机号'
  end
  post 'delete' do

    status 200 #修改post默认返回状态

    mobile = params[:mobile]
    result = DeliveryUser.where(mobile: mobile).delete
    {msg: "配送员删除成功,信息为#{result.to_json}!", flag: 1}
  end



  #需要身份验证的接口
  resource do

    #路由之前身份认证
    before do
      authenticate_deliveryUser
    end

    desc '更新配送员位置信息' do

    end
    params do
      requires :token, type: String, desc: '身份认证token'
      requires :longitude, type: Float, desc: '位置纬度'
      requires :latitude, type: Float, desc: '位置经度'
      requires :position, type: String, desc: '位置描述'
    end
    post 'update_position' do

      status 200 #修改post默认返回状态

    end

    desc '配送员注销' do
      detail '返回结果:{flag:(1:成功,0:失败),msg:提示信息}'
    end
    params do
      requires :token, type: String, desc: '身份认证token'
    end
    post 'login_out' do

      status 200 #修改post默认返回状态
      current_deliveryUser.update_attribute(:authentication_token, "")
      {msg: "注销成功!", flag: 1}
    end
  end


end