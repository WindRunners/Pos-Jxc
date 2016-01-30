class ProductsController < ApplicationController

  before_action :set_product, only: [:show, :edit, :update, :destroy]

  skip_before_action :authenticate_user!, only: [:desc, :preview]

  def searchByQrcode

    begin
      @product = Product.shop(current_user).find_by(:qrcode => params[:qrcode]) if current_user.present?
    rescue
    end

    if @product
      respond_to do |format|
        format.json { render :json => {qrcode: @product.qrcode,
                                       id: @product.id,
                                       name: @product.title,
                                       price: @product.price}.to_json }
      end
    else
      respond_to do |format|
        format.json { render :json => "{}" }
      end
    end

  end

  def search

    p params

    @result = Product.solr_search {
      fulltext params[:search]
    }

  end

  # GET /products
  # GET /products.json
  def index


    @state = params[:state] || 'online'

    respond_to do |format|
      format.html
      format.json { render json: ProductsDatatable.new(view_context, current_user) }
    end
  end

  def warehouse_index

    gon.searchBar = true

    conditions = {category_id: params[:category_id],
                  tag: 'JYD',
                  searchText: params[:searchText],
                  page: params[:page],
                  per: 20}
    products = Warehouse::Product.where(conditions)

    @products = Kaminari::PaginatableArray.new(
        products, {
        :limit => products.http_response['X-limit'].to_i,
        :offset => products.http_response['X-offset'].to_i,
        :total_count => products.http_response['X-total'].to_i
    })

    json = {}

    @products.each do |product|
      json[product.id] = product
    end

    gon.products = json

    respond_to do |format|
      format.html
      format.js {render_js warehouse_index_products_path(page:params[:page]) }
    end

  end

  def warehouse_show

    gon.searchBar = true

    @product = Warehouse::Product.find(params[:product_id])

    gon.product = @product

    @top_products = Warehouse::Product.where(top: true)

    json = {}

    @top_products.each do |product|
      json[product.id] = product
    end

    gon.products = json
  end

  # GET /products/1
  # GET /products/1.json
  def show

    if @product.mobile_category.present?
      @top_products = @product.mobile_category.products.order_by(:sale_count => :desc).limit(5)
    else
      @top_products = []
    end

  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
  end

  def rack
    url = RestConfig::PRODUCT_SERVER

    url += 'api/v1/product/id?id=' + params[:product_id]


    headers = {}
    headers['X-Warehouse-Rest-Api-Key'] = '5604a417c3666e0b7300001a'
    headers['Authentication-Token'] = '4Kzp1iyj4DiHVPhv4JVm'

    begin
      response = RestClient.get(url, headers)
    rescue
      render :new, notice: '该产品不存在'
      return
    end


    json = JSON.parse(response.body)


    begin
      @product = Product.shop(current_user).find(json['id'])

      respond_to do |format|
        format.html { redirect_to @product, notice: '该产品已存在.' }
        format.js
      end
    rescue
      @product = Product.new(json)

      if params[:stock].blank?
        @product.state = State.find_by(value: "offline")
      else
        @product.purchasePrice = params[:purchasePrice]
        @product.price = params[:price]
        @product.stock = params[:stock]
        @product.state = State.find_by(value: "online")
      end

      if @product.shop(current_user).save
        respond_to do |format|
          format.html { redirect_to @product, notice: '该产品添加成功.' }
          format.js
        end
      else
        respond_to do |format|
          format.html { render :new }
          format.js
        end
      end
    end
  end

  # POST /products
  # POST /products.json
  def create

    url = RestConfig::PRODUCT_SERVER

    url += 'api/v1/product/qrcode?qrcode=' + params[:qrcode] if params[:qrcode].present?

    url += 'api/v1/product/id?id=' + params[:id] if params[:id].present?

    headers = {}
    headers['X-Warehouse-Rest-Api-Key'] = '5604a417c3666e0b7300001a'
    headers['Authentication-Token'] = '4Kzp1iyj4DiHVPhv4JVm'


    begin
      response = RestClient.get(url, headers)
    rescue
      return
    end


    json = JSON.parse(response.body)



    begin
      @product = Product.shop(current_user).find(json['id'])

      render_js product_path @product, notice: '该产品已存在.'
    rescue
      @product = Product.new(json)
      @product.state = State.find_by(value: "offline")
      if @product.shop(current_user).save
        render_js product_path @product, notice: '该产品添加成功.'

        #添加字典数据
        ['brand', 'specification', 'origin', 'manufacturer'].each do |field|
          name = @product[field]
          unless name.blank?
            Dictionary.find_or_create_by({'userinfo_id' => current_user.userinfo.id.to_s, 'type' => 'product', 'subtype' => field, 'name' => name})
          end
        end

        redirect_to @product, notice: '该产品添加成功.'
      else
        render :new
      end
    end
  end

  def desc
    @product = Product.shop_id(params[:userinfo_id]).find(params[:product_id])

    @product.shop_id(params[:userinfo_id]).inc(:exposure_attrive_num => 1)

    render :layout => false
  end

  def preview
    @product = Product.shop_id(params[:userinfo_id]).find(params[:product_id])

    render :layout => false
  end

  def demo

    headers = {}
    headers['X-Warehouse-Rest-Api-Key'] = '5604a417c3666e0b7300001a'
    headers['Authentication-Token'] = '4Kzp1iyj4DiHVPhv4JVm'


    url = RestConfig::PRODUCT_SERVER + 'api/v1/product/all'

    response = RestClient.get(url, headers)


    json = JSON.parse(response.body)

    json.each do |p|
      begin
        @product = Product.with(collection: current_user.shop_id).find(p['id'])
      rescue
        @product = Product.new(p)
        @product.price = Faker::Commerce.price
        @product.purchasePrice = @product.price * 0.8
        @product.stock = Faker::Number.between(1, 10)
        @product.integral = Faker::Number.between(1, 10)
        @product.state = State.find_by(name: "已上架")

        @product.shop(current_user).save!
        #
      end
    end

    redirect_to products_url
  end

  def demo_stress

    headers = {}
    headers['X-Warehouse-Rest-Api-Key'] = '5604a417c3666e0b7300001a'
    headers['Authentication-Token'] = '4Kzp1iyj4DiHVPhv4JVm'


    url = RestConfig::PRODUCT_SERVER + 'api/v1/product/all'

    response = RestClient.get(url, headers)


    json = JSON.parse(response.body)

    500.times do

      p = json[Random.rand(0..json.count-1)]

      p.delete('id')

      @product = Product.new(p)
      @product.price = Faker::Commerce.price
      @product.purchasePrice = @product.price * 0.8
      @product.stock = Faker::Number.between(1, 10)
      @product.integral = Faker::Number.between(1, 10)
      @product.state = State.find_by(name: "已上架")

      @product.shop(current_user).save!
    end

    redirect_to products_url
  end


  # PATCH/PUT /products/1
  # PATCH/PUT /products/1.json
  def update

    p params

    respond_to do |format|

      if params[:product].blank?
        render :show
        return
      end


      format.js do

        if @product.shop(current_user).update(product_params)
          render_js product_path(@product)
        else
          render :edit
        end
      end

      format.json do
        @product.shop(current_user).update(product_params)
        respond_with_bip(@product)
      end


    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    @product.shop(current_user).destroy
    respond_to do |format|
      format.html { redirect_to products_url, notice: 'Product was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def state
    @product = Product.shop(current_user).find(params[:product_id])

    if @product.state.value == 'online'
      @product.state = State.find_by(value: 'offline')
    else
      @product.state = State.find_by(value: 'online')
    end



    if @product.shop(current_user).save
      notice = "商品#{@product.state.name}成功"
    else
      notice = "商品#{@product.state.name}失败,#{@product.errors.full_messages.join(',')}"
    end

    render_js product_path(@product), notice

  end

  def statisticData
    dates = params[:retailDateRang].split(" - ") if params[:retailDateRang].present?
    if dates.blank?
      today = Time.now
      dates = [today.beginning_of_month.strftime("%Y-%m-%d")]
      dates << (today - 1.day).strftime("%Y-%m-%d")
    end
    Rails.logger.info "dates===////#{dates}"

    #商品曝光排行榜
    @options = {:xAxis => {:labels => {:rotation => -45, :align => :right}}}
    @options[:title] = {:text => "商品曝光排行TOP10"}
    @result = Array.new
    @products = Product.shop(current_user).order_by(:exposure_num => :desc).limit(10)
    @exposureNum = 0
    map = %Q{
      function() {
        emit(1, {exposureNum: this.exposure_num})
      }
    }
    reduce = %Q{
      function(key, values) {
        exposureNum = 0;
        values.forEach(function(value) {
          exposureNum += value.exposureNum
        });
        return {exposureNum: exposureNum}
      }
    }
    productStatistics = Product.shop(current_user).map_reduce(map, reduce).out(:inline => true)
    begin
      @exposureNum = productStatistics.to_a[0]["value"]["exposureNum"].to_f if !productStatistics.empty?
    rescue
    end
    # @products.each {|p| @exposureNum += p.exposure_num}
    exposureNumProducts = @products.map {|p| [p.title, p.exposure_num]}
    exposureAttriveNumProducts = @products.map {|p| [p.title, p.exposure_attrive_num]}
    @result << {:name => '商品曝光次数', :data => exposureNumProducts}
    @result << {:name => '商品曝光到达次数', :data => exposureAttriveNumProducts}

    #商品购买排行榜
    @purchaseOptions = @options
    @purchaseOptions[:title] = {:text => "商品购买排行TOP10"}
    @purchaseResults = Array.new
    @purchaseProducts = StatisticTotal.where(:userinfo_id => current_user.userinfo.id.to_s).order_by(:total_quantity => :desc).limit(10)
    map = %Q{
      function() {
        emit(1, {totalQuantity: this.total_quantity})
      }
    }
    reduce = %Q{
      function(key, values) {
        totalQuantity = 0;
        values.forEach(function(value) {
          totalQuantity += value.totalQuantity
        });
        return {totalQuantity: totalQuantity}
      }
    }
    productPurchaseStatistics = StatisticTotal.where(:userinfo_id => current_user.userinfo.id.to_s, :complete_date => {"$gte" => dates[0], "$lte" => dates[1]}).map_reduce(map, reduce).out(:inline => true)
    @totalQuantity = 0
    begin
      @totalQuantity = productPurchaseStatistics.to_a[0]["value"]["totalQuantity"].to_f if !productPurchaseStatistics.empty?
    rescue
    end
    purchaseStatistics = @purchaseProducts.map do |st|
      begin
        [Product.shop(current_user).find(st.product_id).title, st.total_quantity]
      rescue
        ["product not exists!", 0]
      end
    end
    @purchaseResults << {:name => "商品购买次数", :data => purchaseStatistics}
    @totalQuantity = 1 if 0 == @totalQuantity
    @exposureNum = 1 if 0 == @exposureNum
  end

  def statistic
    
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_product
    @product = Product.shop(current_user).find(params[:id])
  end


  # Never trust parameters from the scary internet, only allow the white list through.
  def product_params
    params.require(:product).permit(:title, :purchasePrice, :price, :integral, :stock, :specification, :qrcode, :tags, :num, :mobile_category_id)
  end

end
