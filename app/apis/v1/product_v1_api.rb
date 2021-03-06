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
    optional :conditions, type: String, desc: '条件JSON字符串 eg{"brand":["茅台","五粮液"],"specification":["1*6","1*3"]}'
  end
  get 'list' do

    online_state = State.where({:value => 'online'}).first
    where_params = {:state_id => online_state.id}
    conditions = params[:conditions]
    if conditions.present?
      condition_data = JSON.parse(conditions)
      condition_data.each do |k,v|
        where_params[k] = {'$in' => v}
      end
    end

    products = Product.shop_id(params[:id]).where(where_params).order_by(:mobile_category_num => :desc)

    # Product.shop_id(params[:id]).where(where_params).inc(:exposure_num => 1)
    # products.each {|p| p.shop_id(params[:id]).inc(:exposure_num => 1) } #遍历递增曝光量太耗时

    present products, with: Entities::Product
  end

  desc '获取小B的热卖商品列表' do
    success Entities::Product
  end
  params do
    requires :id, type: String, desc: '小B的ID'
  end
  get 'list_by_sales' do


    online_state = State.where({:value => 'online'}).first
    where_params = {:state_id => online_state.id}
    products = Product.shop_id(params[:id]).where(where_params).limit(50).order_by(:sale_count => :desc)

    present products, with: Entities::Product
  end

  desc '获取OA的闪屏广告'
  get 'splash_screen' do
    array = []

    splash=Splash.first
    if splash.present?
      array << {img:splash.avatar.url, seconds:splash.stop_seconds}
    end
  end

  desc '获取小B的轮播列表'
  params do
    requires :id, type: String, desc: '小B的ID'
  end
  get 'slideshow' do
    array = []

    carousels = Carousel.all

    carousels.each do |carousel|
      array << {img:carousel.avatar, url:carousel.url}
    end

    array
  end

  desc '获取小B的促销列表'
  params do
    requires :id, type: String, desc: '小B的ID'
  end
  get 'promotion' do
    promotions = Array.new
    fullReductions = FullReduction.where(:userinfo_id => params[:id], :aasm_state => "beging")
    fullReductions.each do |f|
      promotions.push({:title => f.name, :url => "#{f.url}#{params[:id]}/#{f.id}/", :img => f.avatar, :products => JSON.parse(Entities::Product.represent(f.participateProducts).to_json)})
    end

    promotionDiscount = PromotionDiscount.where(:userinfo_id => params[:id], :aasm_state => "beging")
    promotionDiscount.each do |f|
      promotions.push({:title => f.title, :url => "#{f.url}#{params[:id]}/#{f.id}/", :img => f.avatar, :products => JSON.parse(Entities::Product.represent(f.participateProducts).to_json)})
    end

    panic_buying = PanicBuying.where(:userinfo => Userinfo.find(params[:id]),:state => 1).each do |f|
      promotions.push({:title => "#{f.beginTime}秒杀", :url => "/activities/skipe_one_index/#{params[:id]}/", :img => f.avatar, :products => JSON.parse(Entities::Product.represent(f.products).to_json)})
    end
    
    promotions
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


  desc '商品查询条件' do
    success Entities::ProductCondition
  end
  params do
    requires :id, type: String, desc: '小B的ID'
  end
  get 'condition_list' do

    userinfo_id = params[:id]
    condition = []
    condition << ProductCondition.new({'type'=>"brand",'name'=>'品牌'})
    condition << ProductCondition.new({'type'=>"specification",'name'=>'规格'})
    condition << ProductCondition.new({'type'=>"origin",'name'=>'来源'})
    condition << ProductCondition.new({'type'=>"manufacturer",'name'=>'厂商'})
    condition.each_index do |i|
      #查询小B下面的条件
      c = condition[i]
      c['data'] = Dictionary.where({'userinfo_id' => userinfo_id, 'type' => 'product', 'subtype' => c['type']})
      condition.delete_at(i) if !c['data'].present?
    end
    present condition, with: Entities::ProductCondition
  end


end
