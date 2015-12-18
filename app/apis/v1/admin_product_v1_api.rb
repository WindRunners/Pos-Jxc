require 'grape'

class AdminProductV1API < Grape::API
  format :json

  use ApiLogger

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


  desc '根据条形码获取商品'
  params do
    requires :qrcode, type: String, desc: '条形码'
    requires :id, type: String, desc: '小B的ID'
  end
  get 'qrcode' do

    qrcode = params[:qrcode]

    url = RestConfig::PRODUCT_SERVER + 'api/v1/product/qrcode?qrcode=' + qrcode

    Rails.logger.info url

    headers = {}
    headers['X-Warehouse-Rest-Api-Key'] = '5604a417c3666e0b7300001a'

    begin
      response = RestClient.get(url, headers)
    rescue
      error!("该产品总库不存在", 202)
      return
    end

    begin
      @product = Product.shop_id(params[:id]).find(json['id'])
      error!("该产品" + @product.state.name, 202)
    rescue
      json = JSON.parse(response.body)
    end

  end

  desc '商品上架'
  params do
    requires :id, type: String, desc: '小B的ID'
    requires :product, type: String, desc: '{"id":"商品id","title":"标题","brand":"品牌","specification":"规格","origin":"产地","manufacturer":厂商,"qrcode":条形码,"purchasePrice":进货价,"price":零售价,"integral":积分,"stock":库存,"avatar_url":缩略图,"thumb_url":大缩略图,"main_url":主图,"desc_url":详情图}'
  end
  post 'online' do
    json = JSON.parse(params[:product])

    begin
      @product = Product.shop_id(params[:id]).find(json['id'])

      error!("该产品" + @product.state.name, 202)
    rescue
      @product = Product.new(json)
      @product.state = State.find_by(name: "已上架")
      if @product.shop_id(params[:id]).save
        {success: 'ok'}
      else
        error!({"message" => @product.errors}, 202)
      end
    end
  end

  desc '修改商品', {
      headers: {
          "Authentication-Token" => {
              description: "用户Token",
              required: true
          }
      }
  }
  params do
    requires :product, type: String, desc: '商品json数据'
  end
  post 'update' do
    authenticate!

    json = JSON.parse(params[:product])

    @product = Product.shop(current_user).find(json['id'])

    json.delete('id')

      if @product.shop(current_user).update(json)
        {success: 'ok'}
      else
        error!({"message" => @product.errors}, 202)
      end
  end

  desc '商品上下架及删除', {
      headers: {
          "Authentication-Token" => {
              description: "用户Token",
              required: true
          }
      }
  }
  params do
    requires :product_id, type: String, desc: '商品ID'
    requires :status, type: String, desc: 'online(上架), offline(下架), destroy(删除)'
  end
  post 'manage' do
    authenticate!

    status = params[:status]

    @product = Product.shop(current_user).find(params[:product_id])

    if status == 'destroy'
      @product.shop(current_user).destroy
      return {success: 'ok'}
    end

    @product.state = State.find_by(value: params[:status])

    if @product.shop(current_user).save
      {success: 'ok'}
    else
      error!({"message" => @product.errors}, 202)
    end
  end




  desc '获取小B的商品列表', {
      headers: {
          "Authentication-Token" => {
              description: "用户Token",
              required: true
          }
      },
    :success => Entities::Admin::Product
  }
  params do
    requires :state, type: String, desc: 'online(出售中), restocking(补货中), offline(已下架), alarm(预警)'
    optional :keyword, type: String, desc: '关键字'
  end
  get 'list' do
    authenticate!

    state = params[:state]

    keyword = params[:keyword] || ''

    products = Product.shop(current_user).any_of({:title => /#{keyword}/}, {:qrcode => /#{keyword}/})

    case state
      when 'online', 'offline'
        status = State.find_by(value:state)
        products = products.where(state:status)
      when 'restocking'
        products = products.where(stock:0)
      when 'alarm'
        #products = products.where(:stock.lte => 10)
        products = products.for_js("this.stock <= this.alarm_stock ")
    end

    products = products.order_by(:sale_count => :desc)

    present products, with: Entities::Admin::Product
  end

  desc '根据条形码获取商品', {
      headers: {
          "Authentication-Token" => {
              description: "用户Token",
              required: true
          }
      },
      :success => Entities::Admin::Product
  }
  params do
    requires :qrcode, type: String, desc: '条形码'
  end
  get 'shop_qrcode' do

    qrcode = params[:qrcode]

    begin
      @product = Product.shop(current_user).find_by(qrcode:qrcode)
      present @product, with: Entities::Admin::Product
    rescue
      error!({"message" => 'not found'}, 202)
    end

  end

  desc '搜索小B的商品列表', {
      headers: {
          "Authentication-Token" => {
              description: "用户Token",
              required: true
          }
      },
      :success => Entities::Admin::Product
  }
  params do
    requires :keyword, type: String, desc: '关键词'
  end
  get 'search' do

    authenticate!

    products = Product.shop(current_user).where({:title => /#{params[:keyword]}/})

    present products, with: Entities::Admin::Product
  end


end