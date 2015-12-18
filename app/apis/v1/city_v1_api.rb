require 'grape'
require 'helpers/city_v1_api_helper'

class CityV1API < Grape::API

  format :json
  include   CityV1APIHelper

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
    present  CityV1APIHelper.current_city(declared(params)), with: Entities::City
  end


  desc '获取当前城市列表' do
    success Entities::City
  end
  params do
    requires :userinfo_id, type: String, desc: '小Bid'
  end
  post 'current_list' do

    status 200
    present  CityV1APIHelper.current_list(declared(params)), with: Entities::City
  end



  desc '获取所有城市' do
    success Entities::City
  end
  params do
    optional :name, type: String, desc: '城市名称{模糊检索使用}'
  end
  post 'all_list' do

    status 200
    present  CityV1APIHelper.all_list(declared(params)), with: Entities::City
  end

end