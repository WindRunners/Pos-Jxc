class UserIntegralsController < ApplicationController
  before_action :set_user_integral, only: [:show, :edit, :update, :destroy]

  # GET /user_integrals
  # GET /user_integrals.json
  def index

    @user_integrals = UserIntegral.page params[:page]
    @cashOrders=CashOrder.all
    @cashes=Cash.all
    @user_integral=UserIntegral.new

    @integrals_totle=0
    @integrals_booked=0 #入账积分
    @integrals_spending=0
    @user_integrals.each do |integral|
      if integral.state==1 && integral.userinfo_id==current_user.userinfo_id
        @integrals_booked=integral.integral+@integrals_booked
      elsif integral.state==2 && integral.userinfo_id==current_user.userinfo_id
        @integrals_spending=integral.integral+@integrals_spending
      end
    end
    @integrals_totle=@integrals_booked-@integrals_spending

    @pay_totle=0
    @pay_o=0
    @pay_q=0
    @cash_totle=0
    @cashOrders.each do |cashOrder|
      if cashOrder.userinfo_id==current_user.userinfo_id #完成订单
        @pay_o=cashOrder.paycost + @pay_o
      else
        @pay_o=0
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

    respond_to do |format|
      format.html
      format.json { render json: UserIntegralsDatatable.new(view_context,current_user) }
    end

  end

  # GET /user_integrals/1
  # GET /user_integrals/1.json
  def show
  end

  # GET /user_integrals/new
  def new
    @user_integral = UserIntegral.new
  end

  # GET /user_integrals/1/edit
  def edit
  end

  # POST /user_integrals
  # POST /user_integrals.json
  def create
    @user_integral = UserIntegral.new(user_integral_params)

    respond_to do |format|
      if @user_integral.state == 1 && @user_integral.type == 3
        @cashOrders=CashOrder.all
        @cashes=Cash.all

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
        @cash_y=0
        @cash_totle=0
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
        @user_integral.integral=@user_integral.cash*100
        @user_integral.userinfo_id=current_user.userinfo_id
        if @user_integral.save && @pay_totle-@user_integral.cash>0
          @cash=Cash.new
          @cash.cash =@user_integral.cash
          @cash.cash_state = 4
          @cash.cash_req_date=Time.now
          @cash.userinfo_id = current_user.userinfo_id
          @cash.save
          format.html { redirect_to @user_integral, notice: 'User integral was successfully created.' }
          format.json { render :show, status: :created, location: @user_integral }
          format.js {render_js user_integrals_url}
        else
          format.html { render :new }
          format.js {render_js user_integrals_url}
          @mes="余额不足，请修改转换金额，在提交"
        end
      else
        if @user_integral.save
          format.html { redirect_to @user_integral, notice: 'User integral was successfully created.' }
          format.json { render :show, status: :created, location: @user_integral }
          format.js {render_js user_integrals_url}
        else
          format.html { render :new }
          format.json { render json: @user_integral.errors, status: :unprocessable_entity }
          format.js {render_js user_integrals_url}
        end
      end
    end
  end

  # PATCH/PUT /user_integrals/1
  # PATCH/PUT /user_integrals/1.json
  def update
    begin
      @cashOrders=CashOrder.all
      @cashes=Cash.all
      @user_integral=UserIntegral.new

      @integrals_totle=0
      @integrals_booked=0 #入账积分
      @integrals_spending=0
      @user_integrals.each do |integral|
        if integral.state==1 && integral.userinfo_id==current_user.userinfo_id
          @integrals_booked=integral.integral+@integrals_totle
        elsif integral.state==0 && integral.userinfo_id==current_user.userinfo_id
          @integrals_spending=integral.integral+@integrals_spending
        end
      end
      @integrals_totle=@integrals_booked-@integrals_spending
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
      rescue
    end

    respond_to do |format|
      if @user_integral.update(user_integral_params) && @pay_totle-@user_integral.cash>0
        format.html { redirect_to @user_integral, notice: 'User integral was successfully updated.' }
        format.json { render :show, status: :ok, location: @user_integral }
        format.js {render_js user_integrals_url}
      else
        format.html { render :edit }
        format.json { render json: @user_integral.errors, status: :unprocessable_entity }
        format.js {render_js user_integrals_url}
      end
    end
  end

  # DELETE /user_integrals/1
  # DELETE /user_integrals/1.json
  def destroy
    @user_integral.destroy
    respond_to do |format|
      format.html { redirect_to user_integrals_url, notice: 'User integral was successfully destroyed.' }
      format.json { head :no_content }
      format.js {render_js user_integrals_url}
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_integral
      @user_integral = UserIntegral.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_integral_params
      params.require(:user_integral).permit(:integral, :state, :type,:order_no,:integral_no,:integral_date,:cash)
    end
end
