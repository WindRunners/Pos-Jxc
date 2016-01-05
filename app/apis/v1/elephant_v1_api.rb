require 'grape'
require 'fileutils'

class ElephantV1Api < Grape::API

  helpers do

    #配送员验证方法
    def authenticate_deliveryUser

      #相当于try catch
      begin
        token = params[:token]

        if token.present?

          payload,header = JWT.decode(params[:token],'key')
          @current_deliveryUser = DeliveryUser.where(_id: payload['user_id']).first
        else
          error!({msg: 'token is nil',flag: 401},401)
        end

      rescue Exception #异常捕获
        error!({msg: 'unauthorized access',flag: 401},401)
      end
      #配送员不存在
      error!({msg: 'unauthorized access',flag: 401},401) if !@current_deliveryUser.present?
    end

    #获取当前配送员方法
    def current_deliveryUser
      @current_deliveryUser
    end


    #获取当前小C
    def current_customerUser

      begin
        customerUser = Customer.find(params[:customer_id])
      rescue Exception=>e #异常捕获
        puts e
        error!('小C认证失败',401)
      end
      customerUser
    end


    #文件上传
    def upload_file(file,save_dir)

        FileUtils.makedirs("public/#{save_dir}") if !File::directory?("public/#{save_dir}") #创建文件夹
        save_url = save_dir+file.filename
        #向dir目录写入文件
        File.open("public/#{save_url}", "wb") do |f|
          f.write(file[:tempfile].read)
        end
        save_url
    end

  end

  rescue_from :all do |e|
    ahoy = Ahoy::Tracker.new
    ahoy.track "exception", {'exception'=> e, 'backtrace' =>e.backtrace}
    error!(e, 500)
  end

  mount API::UserV1API => 'user'

  mount AdminUserV1API => 'admin/user'

  mount AdminProductV1API => 'admin/product'

  mount ProductV1API => 'product'

  mount AnnouncementV1API => 'announcement'

  mount OrderV1API => 'order'

  mount PaymentV1API => 'payment'

  mount MarketOrderV1API => 'marketorder'

  #挂载配送员API
  mount DeliveryUserV1API => 'deliveryUser'
  mount SearchV1API => 'search'
  mount GiftBagV1API => 'giftBag'
  mount SpiritRoomV1API => 'spiritRoom'
  mount FullReductionV1API => 'fullReduction'
  mount CouponV1API => 'coupon'
  mount PromotionDiscountV1API => 'promotionDiscount'
  mount CashRequestV1API =>'cashRequest'
  mount StatisticV1API => 'statistic'
  mount DeliveryOrderV1API => 'deliveryOrder'
  mount UintegralV1API => 'uintegral'


  mount ChateauV1API => 'chateau'

  mount WineV1API => 'wine'

  mount CityV1API => 'city'



  add_swagger_documentation base_path: 'api/v1', hide_format: true
end

