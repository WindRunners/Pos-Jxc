class ImportBagsController < ApplicationController
  before_action :set_import_bag, only: [:show, :edit, :update, :destroy,:deal,:gift_bags]


  # GET /import_bags
  # GET /import_bags.json
  def index

    name = params[:name]
    business_user = params[:business_user]
    sender_mobile = params[:sender_mobile]
    workflow_state = params[:workflow_state]

    whereParams = {'user_id'=> current_user.id}
    whereParams['name'] = /#{name}/ if name.present?
    whereParams['business_user'] = /#{business_user}/ if business_user.present?
    whereParams['sender_mobile'] = /#{sender_mobile}/ if sender_mobile.present?
    if !workflow_state.nil? && workflow_state != 'default'
      whereParams['workflow_state'] = workflow_state=='' ? nil : workflow_state
    end

    @import_bags = ImportBag.where(whereParams).page(params[:page])
  end

  # GET /import_bags/1
  # GET /import_bags/1.json
  def show

    #回显商品列表
    set_product_list
    @work_flow_tracks = WorkFlowTrack.where(import_bag_id: @import_bag.id).order('created_at desc').page(params[:page])
  end

  # GET /import_bags/new
  def new
    @import_bag = ImportBag.new
    @product_list = [];
  end

  # GET /import_bags/1/edit
  def edit

    #回显商品列表
    set_product_list
    # puts "商品列表:#{@product_list.to_json}"
  end

  # POST /import_bags
  # POST /import_bags.json
  def create

    puts "礼包创建1"

    @import_bag = ImportBag.new(import_bag_params)
    @import_bag.product_list = get_product_list
    @import_bag.userinfo = current_user.userinfo
    @import_bag.user = current_user

    puts "礼包创建2"


    respond_to do |format|
      if @import_bag.save

        # result['flag'] = 1
        # result['data'] = get_render_js import_bag_path(@import_bag)
        # format.js {render_js import_bag_path(@import_bag) }
        # format.html { redirect_to @import_bag, notice: '礼包创建成功!' }
        # get_render_json(flag,data={},path='')
        format.json { render json: get_render_json(1,nil,import_bag_path(@import_bag)) }
      else
        # result['flag'] = 0
        # result['data'] = @import_bag.errors.messages
        # get_post_product_list
        # format.html { render :new }
        format.json { render json: get_render_json(0,@import_bag.errors.messages) }
      end
    end
  end

  # PATCH/PUT /import_bags/1
  # PATCH/PUT /import_bags/1.json
  def update

    #验证权限
    authorize @import_bag

    @import_bag.product_list = get_product_list
    @import_bag.userinfo = current_user.userinfo
    @import_bag.user = current_user

    respond_to do |format|
      if @import_bag.update(import_bag_params)

        format.json { render json: get_render_json(1,nil,import_bag_path(@import_bag)) }
        # result['flag'] = 1
        # result['data'] = get_render_js import_bag_path(@import_bag)
        # format.js {render_js import_bag_path(@import_bag) }
        # # format.html { redirect_to @import_bag, notice: '礼包更新成功!' }
        # format.json { render :show, status: :ok, location: @import_bag }
      else
        # get_post_product_list
        # format.html { render :edit }
        format.json { render json: get_render_json(0,@import_bag.errors.messages) }
        # format.json { render json: @import_bag.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /import_bags/1
  # DELETE /import_bags/1.json
  def destroy

    #验证权限
    authorize @import_bag

    @import_bag.destroy
    respond_to do |format|
      format.js {render_js import_bags_path }
      # format.html { redirect_to import_bags_url, notice: 'Import bag was successfully destroyed.' }
      format.json { head :no_content }
    end
  end


  #获取商品表格数据
  def products_table_data

    length = params[:length].to_i #页显示记录数
    start = params[:start].to_i #记录跳过的行数

    searchValue = params[:search][:value] #查询
    searchParams = {}
    searchParams['title'] = /#{searchValue}/

    tabledata = {}
    totalRows = Product.shop_id(current_user['userinfo_id']).where(searchParams).count
    tabledata['data'] = Product.shop_id(current_user['userinfo_id']).where(searchParams).page((start/length)+1).per(length)
    tabledata['draw'] = params[:draw] #访问的次数
    tabledata['recordsTotal'] = totalRows
    tabledata['recordsFiltered'] = totalRows

    respond_to do |format|
      format.js {render_js import_bags_path }
      # format.html { redirect_to import_bags_url, notice: 'Import bag was successfully destroyed.' }
      format.json { render json: tabledata }
    end
  end


  #礼包节点事件保存
  def deal

    state = params[:state] #节点
    event = params[:event] #事件
    memo = params[:memo] #备注

    #验证state event 是否合法

    if @import_bag.import_bag_receivers.count == 0
      respond_to do |format|
        format.js {render_js import_bag_import_bag_receivers_path(@import_bag)}
      end
      # redirect_to import_bag_import_bag_receivers_path(@import_bag), notice: '请维护礼包收礼人信息!'
      return
    end

    #验证权限
    authorize @import_bag

    respond_to do |format|

      if state == 'new' #发起审核
        if event == 'submit'
          @import_bag.submit!(current_user,memo) #发起请求
        else
          @import_bag.cancel!(current_user,memo) #作废礼包
        end
      elsif state == 'first_check' #一级审核
        if event == 'pass'
          @import_bag.pass!(current_user,memo) #通过
        else
          @import_bag.un_pass!(current_user,memo) #不通过
        end
      else state == 'second_check' #二级审核
        if event == 'pass'
          @import_bag.pass!(current_user,memo) #通过
        else
          @import_bag.un_pass!(current_user,memo) #不通过
        end
      end

      format.js {render_js import_bags_path }
      # format.html { redirect_to @import_bag, notice: '礼包审核发起成功!' }
      format.json { render :show, status: :ok, location: @import_bag }
    end
  end

  # 礼包审核处理列表
  def deal_list

    @import_bag = ImportBag.new
    # puts "#列表控制:#{policy(@import_bag).canFirstCheck?}"

    #进行权限控制
    states = []
    states << 'first_check' if policy(@import_bag).hasFirstCheckRole?
    states << 'second_check' if policy(@import_bag).hasSecondCheckRole?

    name = params[:name]
    business_user = params[:business_user]
    sender_mobile = params[:sender_mobile]

    whereParams = {'userinfo_id'=> current_user['userinfo_id']}
    whereParams['name'] = /#{name}/ if name.present?
    whereParams['business_user'] = /#{business_user}/ if business_user.present?
    whereParams['sender_mobile'] = /#{sender_mobile}/ if sender_mobile.present?
    @import_bags = ImportBag.where(whereParams).in(workflow_state: states).page(params[:page])
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_import_bag
      @import_bag = ImportBag.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def import_bag_params
      params.require(:import_bag).permit(:name, :business_user, :business_mobile, :sender_mobile, :product_list, :price, :expiry_days, :memo)
    end


    def get_product_list

      product_list = {}
      product_id_array = params[:product_id] #获取商品id
      product_num_array = params[:product_num] #获取商品数量数组
      product_id_array.each_with_index do |item, index|

        if !item.present? || !product_num_array[index].present?
          next
        end
        product_list[item] = {'count' => product_num_array[index].to_i}
      end
      product_list
    end


    #获取post提交的商品列表
    def get_post_product_list

      @product_list = []
      product_id_array = params[:product_id] #获取商品id
      product_num_array = params[:product_num] #获取商品id
      product_title_array = params[:product_title] #获取商品id
      product_avatar_url_array = params[:product_avatar_url] #获取商品缩略图
      product_id_array.each_with_index do |item, index|
        next if !item.present?
        product = Product.new(:title=>product_title_array[index])
        product['count'] = product_num_array[index]
        product['id'] = product_id_array[index]
        product.avatar_url = product_avatar_url_array[index]
        @product_list << product
      end
    end


    def set_product_list

      #回显商品列表
      @product_list = Product.shop_id(current_user['userinfo_id']).where({:id=>{'$in' => @import_bag.product_list.keys}}) if @import_bag.product_list.present?

      if @product_list.present?

        product_list = []
        @product_list.each do |product|
          # puts "数量:#{@import_bag.product_list[product.id.to_s]['count']}"
          product["count"] = @import_bag.product_list[product.id.to_s]['count'] #设置数量属性
          product_list << product
        end

        @product_list = product_list
      else
        @product_list = []
      end


    end


end
