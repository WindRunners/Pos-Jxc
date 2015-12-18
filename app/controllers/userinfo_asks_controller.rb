class UserinfoAsksController < ApplicationController
  before_action :set_userinfo_ask, only: [:show, :edit, :update, :destroy]
  skip_before_action :authenticate_user!
  before_action :auth?
  # GET /userinfo_asks
  # GET /userinfo_asks.json
  def index
    @userinfo_asks = UserinfoAsk.all
  end

  # GET /userinfo_asks/1
  # GET /userinfo_asks/1.json
  def show
  end

  # GET /userinfo_asks/new
  def new
    @userinfo_ask = UserinfoAsk.new
  end

  # GET /userinfo_asks/1/edit
  def edit
  end

  # POST /userinfo_asks
  # POST /userinfo_asks.json
  def create
    @userinfo_ask = UserinfoAsk.new(userinfo_ask_params)

    respond_to do |format|
      if @userinfo_ask.save
        format.html { redirect_to @userinfo_ask, notice: 'Userinfo ask was successfully created.' }
        format.json { render :show, status: :created, location: @userinfo_ask }
      else
        format.html { render :new }
        format.json { render json: @userinfo_ask.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /userinfo_asks/1
  # PATCH/PUT /userinfo_asks/1.json
  def update
    respond_to do |format|
      if @userinfo_ask.update(userinfo_ask_params)
        format.html { redirect_to @userinfo_ask, notice: 'Userinfo ask was successfully updated.' }
        format.json { render :show, status: :ok, location: @userinfo_ask }
      else
        format.html { render :edit }
        format.json { render json: @userinfo_ask.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /userinfo_asks/1
  # DELETE /userinfo_asks/1.json
  def destroy
    @userinfo_ask.destroy
    respond_to do |format|
      format.html { redirect_to userinfo_asks_url, notice: 'Userinfo ask was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_userinfo_ask
      @userinfo_ask = UserinfoAsk.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def userinfo_ask_params
      params.require(:userinfo_ask).permit(:shopname, :approver, :pdistance_state, :pdistance_ask, :ask_date, :rqe_date)
    end
  def auth?
    @app_key = request.headers['appkey']
  end
end
