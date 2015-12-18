require 'grape'
require 'rack/contrib'
class UserV1API < Grape::API
  use Rack::JSONP
  format :json

  helpers do
    def ahoy
      @ahoy ||= Ahoy::Tracker.new
    end

    def current_user
      token = headers['Authentication-Token']
      @current_user = User.find_by(authentication_token:token)
    rescue
      error!('401 Unauthorized', 401)

    end

    def authenticate!

      error!('401 Unauthorized', 401) unless current_user
    end

  end

  use ApiLogger

  desc '根据手机号查找用户'
  params do
    requires :mobile, type: String, desc: '手机号'
  end
  post 'finduser' do
    begin
      user = User.find_by(mobile: params[:mobile])
    rescue
      {:mobile => params[:mobile], :message => '手机号未注册'}
    end
  end

  desc '根据手机号及检验码向该手机号发送检验码'
  params do
    requires :mobile, type: String, desc: '手机号'
    requires :code, type: String, desc: '检验码'
    optional :type, type: String, desc: '短信设置sms,语音设置voice'
  end
  post 'verifycode' do
    type = params[:type] || 'sms'
    code = params[:code]
    # smslog = Smslog.new(params.to_hash())
    #
    # smslog.save
    # # unless params[:signup].blank?
    #   user = User.where(mobile: params[:mobile])

    #   puts use#r.blank?

    #   unless user.blank? then
    #     error!("手机号已被注册", 202)
    #     return
    #   end
    # end

    ChinaSMS.use :yunpian, password: '9525738f52010b28d1b965e347945364'


    if type == 'sms' then # 通用接口
      ChinaSMS.to params[:mobile], '【酒运达】您的验证码是' + code
    else #语音接口
      ChinaSMS.voice params[:mobile], code
    end

    # begin
    #   user=User.find_by(:mobile=>"#{params[:mobile]}")
    #   user.update_attributes(:tmpcode=> code)
    # rescue
    # end

    {message: '验证码已发送，请稍等...'}
  end

  desc '创建小B' do
    success Entities::Userinfo
  end
  params do
    requires :lat, type: Float, desc: '纬度'
    requires :lng, type: Float, desc: '经度'
  end
  post :signup do

    user = User.new

    user.mobile = Faker::Number.number(11)
    user.password = user.mobile
    user.email = Faker::Internet.email
    user.step = Faker::Number.between(1, 9)

    if user.save
      userinfo = Userinfo.new

      userinfo.name = Faker::Name.name
      userinfo.pdistance = Faker::Number.between(200, 1000)
      userinfo.shopname = Faker::Company.name
      userinfo.address = Faker::Address.street_address
      userinfo.location = [params[:lat], params[:lng]]
      userinfo.user = user

      if userinfo.save
        userinfo
      else
        error!({"message" => userinfo.errors}, 202)
      end
    else
      error!({"message" => user.errors}, 202)
    end
  end


  desc '小C根据经纬度获取最近的小B' do
    success Entities::Userinfo
  end
  params do
    requires :lat, type: Float, desc: '纬度'
    requires :lng, type: Float, desc: '经度'
  end
  get :shop do
    center = [params[:lat], params[:lng]]

    radius = 1000

    userinfo = Userinfo.near(location: center).limit(5)

    present userinfo, with: Entities::Userinfo
  end

  desc 'OA获取小B的信息通过经纬度'
  params do
    requires :lat, type: Float, desc: '纬度'
    requires :lng, type: Float, desc: '经度'
  end
  get :shopinfo do
    array=[]
     center=[params[:lat],params[:lng]]
     us=Userinfo.find_by(:location => center)
    callback= params[:callback]
    array << { shopname: "#{us.shopname}",address: "#{us.address}", pusher: "#{us.pusher}" ,pusher_phone: "#{us.pusher_phone}" ,pdistance:"#{us.pdistance}"}

  end


  params do
    requires :password, type: String, desc: '密码'
  end
  get :generateproduct do


    if params[:password] != "admin" then
      error!({"message" => "error"}, 401)
      return
    end

    headers = {}
    headers['X-Warehouse-Rest-Api-Key'] = '5604a417c3666e0b7300001a'
    headers['Authentication-Token'] = '4Kzp1iyj4DiHVPhv4JVm'


    url = RestConfig::PRODUCT_SERVER + 'api/v1/product/all'

    response = RestClient.get(url, headers)


    json = JSON.parse(response.body)

    users = User.all

    users.each do |user|
      if Product.with(collection: user.shop_id).all.size > 0
        p user.shop_id + "has already added"
        next
      end

      json.each do |p|
        begin
          @product = Product.with(collection: user.shop_id).find(p['id'])
        rescue
          @product = Product.new(p)
          @product.price = Faker::Commerce.price
          @product.purchasePrice = @product.price * 0.8
          @product.stock = Faker::Number.between(1, 10)
          @product.integral = Faker::Number.between(1, 10)
          @product.state = State.find_by(name: "已上架")

          @product.shop(user).save!
          #
        end
      end

      p user.shop_id
    end

    {success: 'ok'}
  end

  desc '修改小b的个人信息',{
           headers:{
              "Authentication-Token" => {
                  description: "用户Token(必填)",
                  required: true
              }
           },
           :entity => Entities::Userinfo
                  }
  params do
    requires :end_business,type:String,desc:  "打烊时间"
    requires :start_business,type:String,desc: "开业时间"
    requires :lowestprice,type:String,desc: "日间配送时间点起送金额"
    requires :fright,type:String,desc:"日间配送时间点配送费"
    requires :fright_time,type:String,desc: "日间配送时间点"
    requires :night_time,type:String,desc: "夜间配送时间点"
    requires :h_lowestprice,type:String,desc: "夜间配送时间点配送金额"
    requires :h_fright,type:String,desc: "夜间配送时间点配送费"
    requires :work_24,type:String,desc: "24小时店标示，true／false"
end
  post :userinfo_modify do
    authenticate!
    array=[]
     begin
       @userinfo=Userinfo.find(@current_user.userinfo_id)
       @userinfo.end_business=params[:end_business]
       @userinfo.start_business=params[:start_business]
       @userinfo.lowestprice=params[:lowestprice].to_i
       @userinfo.fright=params[:fright].to_i
       @userinfo.fright_time=params[:fright_time]
       @userinfo.night_time=params[:night_time]
       @userinfo.h_lowestprice=params[:h_lowestprice].to_i
       @userinfo.h_fright=params[:h_fright].to_i
       @userinfo.work_24=params[:work_24]
       @userinfo.save
       array <<  {end_business: "#{@userinfo.end_business}",start_business: "#{@userinfo.start_business}",lowestprice:"#{@userinfo.lowestprice}",fright:"#{@userinfo.fright}",night_time:"#{@userinfo.night_time}",fright_time:"#{@userinfo.fright_time}",h_lowestprice:"#{@userinfo.h_lowestprice}",h_fright:"#{@userinfo.h_fright}",work_24:"#{@userinfo.work_24}"}
     rescue
       array << {messages: "用户修改失败" , state: "1"}
     end
  end

  desc '修改用户(小b)登录密码',{
                      headers:{
                          "Authentication-Token" => {
                              description: "用户Token(必填)",
                              required: true
                          }
                      }
                  }
  params do
    # optional :old_password,type:String,desc:  "旧密码"
    requires :old_password,type:String,desc:  "旧密码"
    requires :password,type:String,desc:  "新密码"
    requires :password_confirmation,type:String,desc: "确认密码"
  end
  post :userpw do
    authenticate!
    begin
      @user=User.find(@current_user.id)
      if params[:old_password].present?
        result=User.find(@current_user.id).valid_password?("#{params[:old_password]}")
        if result==true
          if params[:password] == params[:password_confirmation]
            @user.password=params[:password]
            @user.save
            array=[{messages:"密码修改成功",sate:"1"}]
          else
            array=[{messages:"密码修改失败，可能是您输入密码不一致",sate:"0"}]
          end
        else
          array=[{messages:"原密码不对",sate:"0"}]
        end
      else
        array=[{messages:"旧密码为空",sate:"0"}]
      end
    rescue
      array=[{messages:"请输入正确的原密码",sate:"0"}]
    end
  end

  desc '获取小b的个人信息'
  params do
    requires :userinfo_id,type: String,desc: "用户的userinfo_id"
  end
  get :userinfo do
    array =[]
      begin
        @userinfo=Userinfo.find(params[:userinfo_id])
        present @userinfo,with: Entities::Userinfo
      rescue
        array << {messages: "获取用户信息失败",state:"0"}
      end
  end

end