module CityV1APIHelper

  #获取当前城市
  def CityV1APIHelper.current_city(params)

    province = params['province'] #省
    city = params['city'] #市
    district = params['district'] #县

    if province.present? && city.present?
      #查询县级的联盟商
      userinfo = Userinfo.where({'province' => province, 'city' => city, 'district' => district}).first
      #查询市级的联盟商
      userinfo = Userinfo.where({'province' => province, 'city' => city}).first if !userinfo.present?
      #查询郑州市的联盟商
      userinfo = Userinfo.where({'province' => '河南省', 'city' => '郑州市'}).first if !userinfo.present?
    else
      #查询郑州市的联盟商
      userinfo = Userinfo.where({'province' => '河南省', 'city' => '郑州市'}).first if !userinfo.present?
    end
    CityV1APIHelper.set_city_info userinfo
  end

  #当前城市列表
  def CityV1APIHelper.current_list(params)
    userinfo_id = params['userinfo_id'] #小Bid
    #查询县级的联盟商
    userinfo = Userinfo.where({'_id' => userinfo_id}).first

    return [] if !userinfo.present?

    #查询小B所在市级下面的联盟商
    CityV1APIHelper.set_list_city_info Userinfo.where({'province' => userinfo['province'], 'city' => userinfo['city']})
  end


  #所有城市列表
  def CityV1APIHelper.all_list(params)

    name = params['name'] #城市名称

    if name.present?
      CityV1APIHelper.set_list_city_info Userinfo.where({'$or'=>[{'province' =>/#{name}/}, {'city' => /#{name}/}, {'district' => /#{name}/}]})
    else
      CityV1APIHelper.set_list_city_info Userinfo.all
    end
  end

  private

  def CityV1APIHelper.set_list_city_info(userinfolist)
    list = []
    return list if !userinfolist.present?
    userinfolist.each do |userinfo|
      list << set_city_info(userinfo)
    end
    list
  end

  def CityV1APIHelper.set_city_info(userinfo)
    userinfo['city'] = userinfo['district'] if userinfo['district'].present?
    userinfo
  end

end