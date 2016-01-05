require 'grape'
require 'helpers/city_v1_api_helper'

class CityV1API < Grape::API

  format :json
  include CityV1APIHelper

  desc '获取当前城市' do
    success Entities::City
  end
  params do
    optional :province, type: String, desc: '省'
    optional :city, type: String, desc: '市'
    optional :district, type: String, desc: '县'
  end
  post 'current_city' do

    status 200
    present CityV1APIHelper.current_city(declared(params)), with: Entities::City
  end


  desc '获取当前城市列表' do
    success Entities::City
  end
  params do
    requires :userinfo_id, type: String, desc: '小Bid'
  end
  post 'current_list' do

    status 200
    present CityV1APIHelper.current_list(declared(params)), with: Entities::City
  end


  desc '获取所有城市' do
    success Entities::City
  end
  params do
    optional :name, type: String, desc: '城市名称{模糊检索使用}'
  end
  post 'all_list' do

    status 200
    present CityV1APIHelper.all_list(declared(params)), with: Entities::City
  end

  get 'push' do
    ios_client = Baidu::CloudPush.new('QKWTjM7bZbc0vs6HsylLGnIO', 'h4VbnLpGDANQqW3oE7OQ0D4X2VtKHSh5')
    android_client = Baidu::CloudPush.new('YSG5VESAS4QsuKhUoiAFdPuH', 'uK7R7g9fX1pvomK1cBMFEmsYjbrGEtT3')



    android_msg = {
        title: "小达快跑",
        description: "您有新的订单,请注意查收",
        notification_builder_id: 0,
        notification_basic_style: "2",
        open_type: 3
    }

    r = android_client.push_single_device('4466689857380983080', android_msg, {msg_type: 1})

    {success:r}

  end

end