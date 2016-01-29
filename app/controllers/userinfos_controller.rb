class UserinfosController < ApplicationController
  before_action :set_userinfo, only: [:show, :edit, :update, :destroy]

  skip_before_action :authenticate_user!
  before_action :auth?

  # GET /userinfos
  # GET /userinfos.json
  def index
    @current_user = current_user

    @cashes = Cash.where(:userinfo_id => @current_user.userinfo_id)
    @cashOrders=CashOrder.where(:userinfo_id => @current_user.userinfo_id, :pay_state => {"$in" => [1, 2]})

    @cash_res=Cash.where(:userinfo_id => @current_user.userinfo_id, :cash_state => 1)
    @cash_yes=Cash.where(:userinfo_id => @current_user.userinfo_id, :cash_state => 4)
    @r_integrals = UserIntegral.where(:userinfo_id => @current_user.userinfo_id, :state => 1)
    @z_integrals = UserIntegral.where(:userinfo_id => @current_user.userinfo_id, :state => 2)

    @cash_res=Kaminari.paginate_array(@cash_res).page(params[:page]).per(10)
    @cash_yes=Kaminari.paginate_array(@cash_yes).page(params[:page]).per(10)
    @cashOrders=Kaminari.paginate_array(@cashOrders).page(params[:page]).per(10)
    @r_integrals=Kaminari.paginate_array(@r_integrals).page(params[:page]).per(10)
    @z_integrals=Kaminari.paginate_array(@z_integrals).page(params[:page]).per(10)

    #金额
    @pay_totle=0.00
    @pay_o=0.00
    @pay_q=0.00
    @cash_totle=0.00
    @cashOrders.each do |cashOrder|
      @pay_o=cashOrder.paycost + @pay_o
    end
    @cash_totle=0
    @cash_y=0
    @cashing_totle=0
    @cashes.each do |cash|
      if cash.cash_state == 2
        @cash_totle=cash.cash + @cash_totle
      elsif cash.cash_state == 1
        @cashing_totle = cash.cash + @cashing_totle
      elsif cash.cash_state == 4
        @cash_y= cash.cash + @cash_y
      end
    end
    @pay_totle=@pay_o-(@cash_totle+@cashing_totle+@cash_y)


    respond_to do |format|
      format.html
      format.js { render_js userinfos_path(page: params[:page]) }
    end
  end

  # GET /userinfos/1
  # GET /userinfos/1.json
  def show
    @user=User.find(current_user.id)
    @uerinfo=Userinfo.new
  end

  # GET /userinfos/new
  def new
    @userinfo=Userinfo.new
  end

  # GET /userinfos/1/edit
  def edit
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
          format.html { render 'audit', layout: false }
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

    @userinfo.location ||= [params[:userinfo][:lat], params[:userinfo][:lng]]
    @user=User.find_by(userinfo_id: @userinfo.id)
    respond_to do |format|
      if @userinfo.update(userinfo_params)
        format.html { redirect_to @userinfo, notice: 'Userinfo was successfully updated.', layout: false }
        format.json { render :show, status: :ok, location: @userinfo }
        format.js { render_js userinfo_path(@userinfo) }
      else
        format.html { render :edit }
        format.json { render json: @userinfo.errors, status: :unprocessable_entity }
        format.js { render_js userinfo_path(@userinfo) }
      end
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
    @user = User.find_by(confirmation_token: params[:confirmation_token])
    result = @user.present?
    p result
    if result
      @user.step=3
      @user.save
      redirect_to products_path
      destroy_token
    else
      redirect_to 'regist_mail', layout: false
    end
  end

  require 'rufus-scheduler'

  def destroy_token
    scheduler = Rufus::Scheduler.new
    scheduler.in '6m' do
      puts 'Hello... Rufus'
      @user.update_attribute(:confirmation_token, "")
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

  def jyd_index
    name_condition=params[:name] || ''
    conditionParams = {}
    conditionParams['shopname'] = /#{name_condition}/ if name_condition.present?
    @userinfos = Userinfo.where(conditionParams).page(params[:page]).order('created_at DESC')
    respond_to do |format|
      format.html
      format.js { render_js jyd_index_userinfos_path() }
    end
  end

  def jyd_new
    @userinfo = Userinfo.new
    @params_action = 'jyd_create'
  end

  def jyd_create
    @userinfo = Userinfo.new(userinfo_params)
    @userinfo.role_marks = ['business']
    respond_to do |format|
      if @userinfo.save
        format.json { render json: get_render_json(1, nil, jyd_index_userinfos_path) }
        # format.js { render_js jyd_index_userinfos_path, notice: 'Userinfo was successfully destroyed.' }
        # format.json { head :no_content }
      else
        format.json { render json: get_render_json(0, @userinfo.errors.messages) }
        # format.js { render_js jyd_index_userinfos_path, notice: 'Userinfo was successfully destroyed.' }
        # format.json { head :no_content }
      end
    end
  end

  def jyd_show
    @userinfo = Userinfo.find(params[:userinfo_id])
  end

  def jyd_edit
    @userinfo = Userinfo.find(params[:userinfo_id])
    @params_action = 'jyd_update'
  end

  def jyd_update
    @userinfo = Userinfo.find(params[:userinfo_id])
    @userinfo.update(userinfo_params)
    respond_to do |format|
      format.html
      format.js { render_js jyd_index_userinfos_path() }
    end
  end

  def jyd_destroy
    @userinfo = Userinfo.find(params[:userinfo_id])
    @userinfo.destroy
    respond_to do |format|
      format.html
      format.js { render_js jyd_index_userinfos_path() }
    end
  end

  def jyd_check
    @userinfo = Userinfo.find(params[:userinfo_id])
    @userinfo.status=1
    if !@userinfo.users.present?
      init_user = @userinfo.users.build();
      init_user.name = @userinfo.name
      init_user.mobile = @userinfo.pusher_phone
      init_user.password = '123456'
      init_user.email = @userinfo.email

      role_array = []
      @userinfo.role_marks.each do |role_mark|

        Role.where(:role_mark => role_mark).each do |role|
          role_array << role.id
        end
      end
      init_user.role_ids = role_array

      init_user.step = 9
      init_user.save
    end
    @userinfo.save
    binding.pry
    respond_to do |format|
      format.html
      format.js { render_js jyd_index_userinfos_path() }
    end
  end

  def jyd_check_out
    @userinfo = Userinfo.find(params[:userinfo_id])
    @userinfo.status=-1
    @userinfo.users.each do |user|
      user.step = 1
      user.save
    end
    @userinfo.save
    respond_to do |format|
      format.html
      format.js { render_js jyd_index_userinfos_path() }
    end
  end


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
    params.require(:userinfo).permit(:name, :address, :shopname, :url, :lat, :lng, :busp, :footp, :pdistance, :district, :city, :province, :integral,
                                     :approver, :pusher, :pusher_phone, :healthp, :taxp, :orgp, :idpb, :idpf, :idnumber, :aseet4, :aseet3, :fright, :lowestprice,
                                     :fright_time, :h_lowestprice, :h_fright, :night_time, :province, :city, :district, :address, :start_business, :end_business,
                                     :status, :email, :role_marks)
  end

  def auth_userinfo_params
    params.require(:userinfo).permit(:name, :address, :shopname, :url, :location, :busp, :footp, :pdistance, :approver, :pusher, :pusher_phone,
                                     :healthp, :taxp, :orgp, :idpb, :idpf, :idnumber, :integral, :created_at, :updated_at)
  end

  def auth?
    @app_key = request.headers['appkey']
  end


  def status_str
    if self.status == 0
      p '未启用'
    end
    if self.status == 1
      p '启用'
    end
    if self.status == -1
      p '禁用'
    end
  end

end
