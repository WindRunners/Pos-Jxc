require 'grape'

class ProductV1API < Grape::API
  format :json

  use ApiLogger

  helpers do

    def ahoy
      @ahoy ||= Ahoy::Tracker.new
    end

  end


  desc '随机添加小B库存数量(1-10)'
  params do
    requires :id, type: String, desc: '小B的ID'
  end
  get 'addstock' do
    products = Product.shop_id(params[:id]).any_of({:stock.exists => false}, {stock:0})
    p products.size
    for product in products
      product.integral = 1
      product.stock = Faker::Number.between(1, 10)
      product.purchasePrice = Faker::Number.between(1, 100)
      product.price = Faker::Number.between(1, 100)
      product.shop_id(params[:id]).save
    end

    {success:'ok'}
  end

  desc '随机添加小B库存数量(1-1000)'
  params do
    requires :id, type: String, desc: '小B的ID'
  end
  get 'addlargestock' do
    products = Product.shop_id(params[:id]).where(stock:0)
    p products.size
    for product in products
      product.stock = Faker::Number.between(1, 1000)
      product.shop_id(params[:id]).save
    end

    {success:'ok'}
  end

  desc '获取小B的商品列表' do
    success Entities::Product
  end
  params do
    requires :id, type: String, desc: '小B的ID'
  end
  get 'list' do

    products = Product.shop_id(params[:id]).all.order_by(:category_name => :desc)

    products.each {|p| p.shop_id(params[:id]).inc(:exposure_num => 1) }

    present products, with: Entities::Product
  end

  desc '获取小B的热卖商品列表' do
    success Entities::Product
  end
  params do
    requires :id, type: String, desc: '小B的ID'
  end
  get 'list_by_sales' do

    products = Product.shop_id(params[:id]).limit(50).order_by(:sale_count => :desc)

    products.each {|p| p.shop_id(params[:id]).inc(:exposure_num => 1) }

    present products, with: Entities::Product
  end

  desc '获取小B的轮播列表'
  params do
    requires :id, type: String, desc: '小B的ID'
  end
  get 'slideshow' do
    array = []

    begin
      carousel=CarouselAsset.find_by(carousel_id: params[:id])
      carouselAssets=CarouselAsset.all
      array << {img:"#{carousel[0].asset.path.split("public")[1]}", url:""} if carousel[0].present?
      array << {img:"#{carousel[1].asset.path.split("public")[1]}", url:""} if carousel[1].present?
      array << {img:"#{carouselAssets[0].img1_path.split(".")[0]}"+".png", url:"#{carouselAssets[0].url1}"} if carouselAssets.present?
      array << {img:"#{carouselAssets[0].img2_path.split(".")[0]}"+".png", url:"#{carouselAssets[0].url2}"} if carouselAssets.present?
    rescue
      carouselAssets=CarouselAsset.all
      array << {img:"#{carouselAssets[0].img1_path.split(".")[0]}"+".png", url:"#{carouselAssets[0].url1}"} if carouselAssets.present?
      array << {img:"#{carouselAssets[0].img2_path.split(".")[0]}"+".png", url:"#{carouselAssets[0].url2}"} if carouselAssets.present?
    end

  end

  desc '获取小B的促销列表'
  params do
    requires :id, type: String, desc: '小B的ID'
  end
  get 'promotion' do
    promotions = Array.new
    fullReductions = FullReduction.where(:userinfo_id => params[:id], :aasm_state => "beging")
    fullReductions.each do |f|
      promotions.push({:title => f.name, :url => "#{f.url}#{params[:id]}/#{f.id}/", :img => f.avatar, :products => JSON.parse(Entities::Product.represent(f.participateProductsById(params[:id])).to_json)})
    end

    promotionDiscount = PromotionDiscount.where(:userinfo_id => params[:id], :aasm_state => "beging")
    promotionDiscount.each do |f|
      promotions.push({:title => f.title, :url => "#{f.url}#{params[:id]}/#{f.id}/", :img => f.avatar, :products => JSON.parse(Entities::Product.represent(f.participateProducts).to_json)})
    end

    promotions
  end

  desc '获取OA的闪屏广告'
  get 'splash_screen' do
    array = []
    splashes = Splash.splashCache
    if SpalashScreenAsset.all.present?
      @spalashScreenAssets=SpalashScreenAsset.all
      if  File:: directory?("public/upload/image/splash_screen/splash_screen_assets/")
        p '-=-='
        Net::HTTP.start("10.99.99.206") { |http|
          resp = http.get("/#{splashes[0].splash_screen_img}")
          p splashes[0].splash_screen_img
          open("public/#{splashes[0].splash_screen_img.split(".")[0]+".png"}", "wb") { |file|
            file.write(resp.body) }
        }
        @spalashScreenAssets[0].update("img_path"=>splashes[0].splash_screen_img)
        @spalashScreenAssets[0].update("seconds"=>splashes[0].stop_seconds)
        p '-=-='
      else
        FileUtils.makedirs("public/upload/image/splash_screen/splash_screen_assets/")
        Net::HTTP.start("10.99.99.206") { |http|
          resp = http.get("/#{splashes[0].splash_screen_img}")
          open("public/#{splashes[0].splash_screen_img.split(".")[0]+".png"}", "wb") { |file|
            file.write(resp.body) }
        }
        @spalashScreenAssets[0].update("img_path"=>splashes[0].splash_screen_img)
        @spalashScreenAssets[0].update("seconds"=>splashes[0].stop_seconds)
      end
    else
      @spalashScreenAsset=SpalashScreenAsset.new

      if  File:: directory?("public/upload/image/splash_screen/splash_screen_assets/")
        Net::HTTP.start("10.99.99.206") { |http|
          resp = http.get("/#{splashes[0].splash_screen_img}")
          p splashes[0].splash_screen_img
          open("public/#{splashes[0].splash_screen_img.split(".")[0]+".png"}", "wb") { |file|
            file.write(resp.body) }
        }
        @spalashScreenAsset.update("img_path"=>splashes[0].splash_screen_img)
        @spalashScreenAsset.update("seconds"=>splashes[0].stop_seconds)
      else
        FileUtils.makedirs("public/upload/image/splash_screen/splash_screen_assets/")
        Net::HTTP.start("10.99.99.206") { |http|
          resp = http.get("/#{splashes[0].splash_screen_img}")
          open("public/#{splashes[0].splash_screen_img.split(".")[0]+".png"}", "wb") { |file|
            file.write(resp.body) }
        }
        @spalashScreenAsset.update("img_path"=>splashes[0].splash_screen_img)
        @spalashScreenAsset.update("seconds"=>splashes[0].stop_seconds)
      end
    end

    spalsh=SpalashScreenAsset.all
    if spalsh.present?
    array << {img:"#{spalsh[0].img_path.split(".")[0]}"+".png", seconds:"#{spalsh[0].seconds}"}
    end
  end

  desc '根据多个商品id，返回商品活动分组信息' do
    success Entities::FullReduction
  end
  params do
    requires :id, type: String, desc: '小B的ID'
    requires :product_ids, type: String, desc: '商品id，多个用逗号分隔'
  end
  get :getProductGroupInfo do
    return {:success => false, :info => "小B不信息不存在"} if 0 == Userinfo.where(:id => params[:id]).count
    resultGroupInfo = {:activities => [], :normal => []}
    productGroupInfo = Hash.new
    product_id_array = params[:product_ids].split(",")
    product_id_array.each do |pid|
      begin
       product = Product.shop_id(params[:id]).find(pid)

       if nil == product.full_reduction_id || 0 == FullReduction.where(:id => product.full_reduction_id, :aasm_state => "beging", :userinfo_id => params[:id]).count
         if productGroupInfo["normal"].blank?
           productGroupInfo["normal"] = [JSON.parse(Entities::Product.represent(product).to_json)]
         else
           productGroupInfo["normal"] << JSON.parse(Entities::Product.represent(product).to_json)
         end
       else
         full_reduction = FullReduction.find(product.full_reduction_id)
         if productGroupInfo[product.full_reduction_id].blank?
           giftCount = 0
           full_reduction.gifts_product_ids.each do |p|
             giftCount += p[:quantity].to_i
           end
           tempFull = JSON.parse(Entities::FullReduction.represent(full_reduction).to_json)
           tempFull["url"] += "#{params[:id]}/#{full_reduction.id}/"
           if "1" == tempFull["preferential_way"]
             tempFull["groupName"] = "满减"
             tempFull["groupTag"] = "满#{tempFull["quota"]}减#{tempFull["reduction"]}"
           elsif "4" == tempFull["preferential_way"]
             tempFull["groupName"] = "买赠"
             tempFull["groupTag"] = "买#{tempFull["purchase_quantity"]}赠#{giftCount}件商品"
           else
             tempFull["groupName"] = "满赠"
             if "2" == tempFull["preferential_way"]
               tempFull["groupTag"] = "满#{tempFull["quota"]}赠#{tempFull["integral"]}积分"
             elsif "3" == tempFull["preferential_way"]
               tempFull["groupTag"] = "满#{tempFull["quota"]}赠#{tempFull["couponIds"].size}张优惠券"
             elsif "5" == tempFull["preferential_way"]
               tempFull["groupTag"] = "满#{tempFull["quota"]}赠#{giftCount}件商品"
             end
           end
           tempFull["products"] = [JSON.parse(Entities::Product.represent(product).to_json)]
           productGroupInfo[product.full_reduction_id] = tempFull
         else
           productGroupInfo[product.full_reduction_id]["products"] << JSON.parse(Entities::Product.represent(product).to_json)
         end
       end
     rescue
       if productGroupInfo["normal"].blank?
         productGroupInfo["normal"] = [{:id => pid, :stock => 0}]
       else
         productGroupInfo["normal"] << {:id => pid, :stock => 0}
       end
     end
    end
    productGroupInfo.each do |key, value|
      if "normal" == key
        resultGroupInfo[:normal] = value
      else
        resultGroupInfo[:activities] << value
      end
    end
    resultGroupInfo
  end
end