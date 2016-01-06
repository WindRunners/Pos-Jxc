class CashesController < ApplicationController
  before_action :set_cash, only: [:show, :edit, :update, :destroy]

  before_action :auth?
  # GET /cashes
  # GET /cashes.json
  def index
    if @app_key.present?
      @cashes = Cash.where(:cash_state =>{"$in" => [1,2,3,9]})
    else
      @cashes = Cash.where(:userinfo_id=>current_user.userinfo_id)
      @cashOrders=CashOrder.where(:userinfo_id=>current_user.userinfo_id)
      @cash=Cash.new
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
      @cashes=Kaminari.paginate_array(@cashes).page(params[:page]).per(10)
      @cashOrders=Kaminari.paginate_array(@cashOrders).page(params[:page]).per(10)
        respond_to do |format|
          format.html{}
          format.json{ render json: CashDatatable.new(view_context,current_user) }
        end
    end
  end

  # GET /cashes/1
  # GET /cashes/1.json
  def show
  end

  # GET /cashes/new
  def new
    @cash = Cash.new
  end

  # GET /cashes/1/edit
  def edit
  end

  # POST /cashes
  # POST /cashes.json
  def create
    if @app_key.present?
      @cash = Cash.new
      @cash.cash=params[:cash]
      @cash.cash_req_date=params[:cash_req_date]
      @cash.cash_back_date=params[:cash_back_date]
      @cash.cash_state=params[:cash_state]
      @cash.userinfo_id=params[:userinfo_id]
      @cash.cash_rno=params[:cash_rno]
      @cash.pay_email=params[:pay_email]
      @cash.pay_name=params[:pay_name]

      respond_to do |format|
        if @cash.save
            @cash=Cash.find_by(:cash_no => params[:cash_rno])
            @cash.cash_back_date=params[:cash_back_date]
            @cash.cash_state=2
            @cash.save
            format.html { redirect_to @cash, notice: '您的申请已审阅，我们将于24小时内对您的申请作出取现' }
            format.json { render json: @cash, status: :created, location: @cash }
          end
      end
    end

      if params[:cheack_cash].present?
        @cash = Cash.new(cash_params)
        if @cash.cash_state==1
          @cash.cash_req_date=Time.now
          # elsif @cash.cash_state==2
          #   @cash.cash_back_date=Time.now
        end
        @cash.cash_name =current_user.name
        @cash.cash_email =current_user.email
        @cash.userinfo_id=current_user.userinfo_id
        begin
          @cashes = Cash.all
          @cashOrders=CashOrder.all
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
                respond_to do |format|
                  if (@pay_totle-@cash.cash)>=0 && @cash.save
                    format.html { redirect_to @cash, notice: '您的申请已审阅，我们将于24小时内对您的申请作出取现' }
                    format.json { render json: @cash, status: :created, location: @cash }
                    format.js { render_js cashes_url}
                  else
                    format.html { render :new }
                    format.json { render json: @cash.errors, status: :unprocessable_entity }
                    flash[:error]="余额不足，请修改请求现金"
                    format.js { render_js new_cash_url}
                  end
                end
        end
      end

  end

  # PATCH/PUT /cashes/1
  # PATCH/PUT /cashes/1.json
  def update
    @cashes = Cash.all
    @cashOrders=CashOrder.all

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
    respond_to do |format|
      if @cash.update(cash_params) && (@pay_totle-@cash.cash)>=0
        format.html { redirect_to @cash, notice: '您的申请已审阅，我们将于24小时内对您的申请作出取现' }
        format.json { render :show, status: :ok, location: @cash }
        format.js { render_js cashes_path}
      else
        format.html { render :edit }
        format.json { render json: @cash.errors, status: :unprocessable_entity,notice: '您的申请的现金超出您的总额，请修改后提交'  }
      end
    end
  end

  # DELETE /cashes/1
  # DELETE /cashes/1.json
  def destroy
    @cash.destroy
    respond_to do |format|
      format.html { redirect_to cashes_url, notice: 'Cash was successfully destroyed.' }
      format.json { head :no_content }
      format.js { render_js new_cash_url}
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cash
      @cash = Cash.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def cash_params
      params.require(:cash).permit(:cash,:cash_state,:cash_req_date,:cash_back_date,:userinfo_id,
                                   :cash_rno,:cash_no,:cash_name,:cash_email,:pay_email,:pay_name)
    end

  def auth?
    @app_key = request.headers['appkey']
  end

end
