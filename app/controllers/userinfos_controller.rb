class UserinfosController < ApplicationController
  before_action :set_userinfo, only: [:show, :edit, :update, :destroy]

  skip_before_action :authenticate_user!
  before_action :auth?

  # GET /userinfos
  # GET /userinfos.json
  def index
  @current_user = current_user
    if @app_key.present?
      @userinfos = Userinfo.all
    elsif @current_user.step ==1     #用户状态1 只能请先去邮箱验证
      render 'userinfos/regist_mail', layout: false
    elsif @current_user.step==3   #用户状态3:邮箱验证完毕：如果用户信息没有创建－》创建；如果有－》修改信息
       begin
         redirect_to edit_userinfo_path(@current_user.id),layout: false
       rescue
         redirect_to new_userinfo_path, layout: false
       end
    elsif @current_user.step==9 || current_user.step==6 #用户状态9: 完成注册准备开店
          @user_integrals = UserIntegral.all
          @integrals_totle=0
          @integrals_booked=0 #入账积分
          @integrals_spending=0
          @user_integrals.each do |integral|
            if integral.state==1 && integral.userinfo_id==current_user.userinfo_id
              @integrals_booked=integral.integral+@integrals_booked
            elsif integral.state==0 && integral.userinfo_id==current_user.userinfo_id
              @integrals_spending=integral.integral+@integrals_spending
            end
          end
          @integrals_totle=@integrals_booked-@integrals_spending
          begin
          @cashes = Cash.where(:userinfo_id => @current_user.userinfo_id)
          @cashOrders=CashOrder.where(:userinfo_id => @current_user.userinfo_id)
          @cash=Cash.new
          #金额
          @pay_totle=0.00
          @pay_o=0.00
          @pay_q=0.00
          @cash_totle=0.00
          @cashOrders.each do |cashOrder|
            if cashOrder.userinfo_id==current_user.userinfo_id #完成订单
              @pay_o=cashOrder.paycost + @pay_o
            else
              @pay_o=0.00
            end
          end
          @cash_totle=0
          @cash_y=0
          @cashing_totle=0
          @cashes.each do |cash|
            if cash.cash_state == 2 && cash.userinfo_id==current_user.userinfo_id
              @cash_totle=cash.cash + @cash_totle
            elsif cash.cash_state == 1 && cash.userinfo_id==current_user.userinfo_id
              @cashing_totle = cash.cash + @cashing_totle
            elsif cash.cash_state == 4 && cash.userinfo_id==current_user.userinfo_id
              @cash_y= cash.cash + @cash_y
            end
          end
          @pay_totle=@pay_o-(@cash_totle+@cashing_totle+@cash_y)
          @cashes=Kaminari.paginate_array(@cashes).page(params[:page]).per(10)
          @cashOrders=Kaminari.paginate_array(@cashOrders).page(params[:page]).per(10)
          @user_integrals=Kaminari.paginate_array(@user_integrals).page(params[:page]).per(10)
          rescue
          end
    elsif @current_user.mobile=="admin"
    @userinfos = Userinfo.all.page(params[:page])
    @userinfo = Userinfo.new
    elsif @current_user.step==4
      render 'userinfos/audit', layout: false
      #data=Userinfo.near(location:[34.746728, 113.642596])
      # coordinate=[34.746728, 113.642596]
      # max_distance=5
      # data= Userinfo.geo_near(coordinate).max_distance(max_distance.fdiv   6371).spherical.distance_multiplier(6371000)
      # render 'audit', layout: false
    end

  end

  # GET /userinfos/1
  # GET /userinfos/1.json
  def show
    if @app_key.present?
      @userinfo=Userinfo.find(params[:id])
      if @userinfo.location.present?
        center = @userinfo.location
        begin
          data = Userinfo.near(location:center)
          for d in data
            lat_lng="{lng: "+d.location[0].to_s+","+"lat: "+d.location[1].to_s+","+"count:"+d.pdistance.to_s+"},"+lat_lng.to_s
          end
          @userinfo.update_attribute("location_data",lat_lng)
          rescue
        end
      end
    elsif current_user.step==3 ||current_user.step==4||current_user.step==1||current_user.step==8
      render 'userinfos/audit', layout: false

    end

  end

  # GET /userinfos/new
  def new
   if current_user.step==9 || current_user.step==6
     redirect_to userinfos_path(current_user.userinfo_id),layout:false
   elsif current_user.step==1
     render 'regist_mail',layout: false
   elsif current_user.step==3
    @userinfo = Userinfo.new
  #  @user = User.find_by(id: car.id)
  #  @user.step=3
  #  @user.save#
    render layout: false
   elsif current_user.step==4
     render 'audit',layout:false
   elsif current_user.mobile=="admin"
     @userinfo = Userinfo.new
     render layout: false
   else
     @userinfo = Userinfo.new
     render layout: false
   end
  end

  # GET /userinfos/1/edit
  def edit
    if current_user.step==9 || current_user.step==6
      redirect_to userinfos_path(current_user.userinfo_id),layout:false
    elsif current_user.step==3
        @user = User.find_by(userinfo_id: current_user.userinfo_id)
            if @user.step==8 #OA审核不成功
              @user.step=3
              @user.save
            elsif @user.step==4
              render 'audit',layout:false
            end
        render layout: false
    elsif current_user.step==4
      render 'audit',layout:false
    elsif current_user.mobile=="admin"
      render layout: false
   end
  end

  # POST /userinfos
  # POST /userinfos.json
  def create
    if params[:lng].present?
      params[:userinfo][:lng]= params[:lng]
      params[:userinfo][:lat]= params[:lat]
      @userinfo = Userinfo.new(auth_userinfo_params)
      @userinfo.location = [@userinfo.lat, @userinfo.lng]
    else
      @userinfo = Userinfo.new(userinfo_params)
      @user=User.find(current_user.id)
      @user.step=4
      @user.save
      @userinfo.location = [@userinfo.lat, @userinfo.lng]
    end
    respond_to do |format|
      if @userinfo.save
          if @app_key.present?
            format.json { render :show, status: :ok, location: @userinfo }
          else
            @userinfo.users<<@user
            format.html { render 'audit',layout: false }
            format.json { render :show, status: :create, location: @userinfo }
          end
      else
        format.html { render :new }
        format.json { render json: @userinfo.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /userinfos/1
  # PATCH/PUT /userinfos/1.json
  def update

    if params[:set_pdistance].present?
      @userinfo_ask=UserinfoAsk.new
      @userinfo_ask.shopname = params[:userinfo][:shopname]
      @userinfo_ask.location = params[:userinfo][:location]
      @userinfo_ask.location_data=params[:userinfo][:location_data]
      @userinfo_ask.pdistance_state=1
      @userinfo_ask.pdistance_ask =params[:userinfopd][:pdistance]
      @userinfo_ask.ask_date = Time.now
      @userinfo.userinfo_asks << @userinfo_ask
    end

      @userinfo.location ||= [params[:userinfo][:lat], params[:userinfo][:lng]]
      @user=User.find_by(userinfo_id:@userinfo.id)


    #@userinfo.idpf=params[:userinfo][:idpf]
    respond_to do |format|
      if @userinfo.update(userinfo_params)
        if @user.step==3
          @user.step=4
          @user.save
          #format.html { redirect_to @userinfo, notice: 'Userinfo was successfully updated.' ,layout:false}
          format.html { render 'audit', notice: 'Userinfo was successfully updated.' ,layout:false}
        elsif @user.step==9
        @user_integral=UserIntegral.new
          @user_integral.integral = @userinfo.integral
          @user_integral.state=1
          @user_integral.type =0
          @user_integral.integral_date =Time.now
          @userinfo.user_integrals << @user_integral
          format.html { redirect_to @userinfo, notice: 'Userinfo was successfully updated.' ,layout:false}
        else
          format.html { redirect_to @userinfo, notice: 'Userinfo was successfully updated.' ,layout:false}
        end
        format.json { render :show, status: :ok, location: @userinfo }
      else
        format.html { render :edit }
        format.json { render json: @userinfo.errors, status: :unprocessable_entity }
      end
      #if @userinfo.save
      #  if @app_key.present?
      #    if @userinfo.update(auth_userinfo_params)
      #       @userinfo.update_attribute(:integral,100000)
      #       @user = User.find_by(:userinfo_id => @userinfo.id)
      #       @user.step=9
      #       @user.save
      #      format.json { render :show, status: :ok, location: @userinfo }
      #    else
      #      format.html { render 'prompt_interface',layout: false }
      #      format.json { render json: @userinfo.errors, status: :unprocessable_entity }
      #    end
      #  else
      #    format.html { render 'prompt_interface',layout: false }
      #    format.json { render json: @userinfo.errors, status: :unprocessable_entity }
      #  end
      #else
      #  if @userinfo.update(userinfo_params)
      #    format.html { redirect_to @userinfo, notice: 'Userinfo was successfully updated.' }
#
      #    format.json { render :json => [@userinfo.add_jpg_url].to_json }
      #  else
      #    format.html { render :edit }
      #    format.json { render json: @userinfo.errors, status: :unprocessable_entity }
      #  end
      #end

    end
  end

  def audit

  end

  # DELETE /userinfos/1
  # DELETE /userinfos/1.json
  def destroy
    @userinfo.destroy
    respond_to do |format|
      format.html { redirect_to userinfos_url, notice: 'Userinfo was successfully destroyed.' }
      format.json { head :no_content }
    end
  end


  def audit
    render layout: false
  end

  def email_active
    @user = User.find_by(confirmation_token:params[:confirmation_token])
    result = @user.present?
    p result
    if result
       @user.step=3
       @user.save
       redirect_to products_path
       destroy_token
    else
       redirect_to 'regist_mail',layout:false
    end
  end

  require 'rufus-scheduler'
  def destroy_token
    scheduler = Rufus::Scheduler.new
    scheduler.in '6m' do
      puts 'Hello... Rufus'
      @user.update_attribute(:confirmation_token,"")
    end

  end

  #def userinfo_edit
  #private
  #  # Use callbacks to share common setup or constraints between actions.
  #  def set_userinfo
  #    @userinfo = Userinfo.find(params[:id])
  #  end

  #  respond_to do |format|
  #    if @userinfo.update(userinfo_params)
  #      format.html { redirect_to @userinfo, notice: 'Userinfo was successfully updated.' }

  #      format.json { render :json => [@userinfo.add_jpg_url].to_json }
  #    else
  #      format.html { render :edit }
  #      format.json { render json: @userinfo.errors, status: :unprocessable_entity }
  #    end
  #  end

  # end


  private

  # Use callbacks to share common setup or constraints between actions.
  def set_userinfo

    if current_user.present?
    @userinfo = Userinfo.find(current_user.userinfo_id)
    else
      @userinfo = Userinfo.find(params[:id])
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def userinfo_params
    params.require(:userinfo).permit(:name, :address, :shopname, :url, :lat, :lng, :busp, :footp, :pdistance,:district,:city,:province, :integral,
                                     :approver,:pusher,:pusher_phone,:healthp, :taxp, :orgp, :idpb, :idpf, :idnumber,:aseet4,:aseet3,:fright,:lowestprice,:fright_time,:h_lowestprice,:h_fright, :start_business,:end_business)
  end

  def auth_userinfo_params
    params.require(:userinfo).permit(:name, :address, :shopname, :url,:location, :busp, :footp, :pdistance,:approver,:pusher,:pusher_phone,
                                     :healthp, :taxp, :orgp, :idpb, :idpf, :idnumber, :integral, :created_at, :updated_at)
  end

  def auth?
    @app_key = request.headers['appkey']
  end

end
