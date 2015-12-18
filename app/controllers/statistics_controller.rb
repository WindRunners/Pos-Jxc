class StatisticsController < ApplicationController
  before_action :set_statistic, only: [:show, :edit, :update, :destroy]

  # GET /statistics
  # GET /statistics.json
  def index
    @statistics = Statistic.all.order(:quantity => "DESC", :retailPrice => "DESC")
    #@statistics = Statistic.where(:retailDate => "2015-10-05")
    buildStatisticData(@statistics)
  end

  # GET /statistics/1
  # GET /statistics/1.json
  def show
  end

  def search
    puts "date======>" + params[:retailDateRang].to_s
    dates = params[:retailDateRang].split(" - ")
    @statistics = Statistic.where({retailDate: {"$gte" => dates[0],"$lte" => dates[1] }}).order(:quantity => "DESC", :retailPrice => "DESC")
    buildStatisticData(@statistics)
    render :index
  end

  # GET /statistics/new
  def new
    @statistic = Statistic.new
  end

  # GET /statistics/1/edit
  def edit
  end

  # POST /statistics
  # POST /statistics.json
  def create
    @statistic = Statistic.new(statistic_params)

    respond_to do |format|
      if @statistic.save
        format.html { redirect_to @statistic, notice: 'Statistic was successfully created.' }
        format.json { render :show, status: :created, location: @statistic }
      else
        format.html { render :new }
        format.json { render json: @statistic.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /statistics/1
  # PATCH/PUT /statistics/1.json
  def update
    respond_to do |format|
      if @statistic.update(statistic_params)
        format.html { redirect_to @statistic, notice: 'Statistic was successfully updated.' }
        format.json { render :show, status: :ok, location: @statistic }
      else
        format.html { render :edit }
        format.json { render json: @statistic.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /statistics/1
  # DELETE /statistics/1.json
  def destroy
    @statistic.destroy
    respond_to do |format|
      format.html { redirect_to statistics_url, notice: 'Statistic was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_statistic
      @statistic = Statistic.find(params[:id])
    end

    def buildStatisticData(statistics)
      hexRandNumArray = []
      @gross_profit = 0.0
      @sales = 0
      @statistics_json = "["
      @statistics.each do |statistic|
        @gross_profit += statistic.quantity * (statistic.retailPrice - statistic.purchasePrice)
        @sales += statistic.quantity
        hexRandNum = rand(0xffffff).to_s(16)
        hexRandNum = rand(0xffffff).to_s(16) unless hexRandNumArray.include?(hexRandNum)
        hexRandNumArray.push hexRandNum
        @statistics_json += "{label:'" + statistic.qrcode + "',data:'" + statistic.quantity.to_s
        @statistics_json += "',color:'#" + hexRandNum + "'},"
      end
      if 2 == @statistics_json.size
        @statistics_json = "["
      end
      @statistics_json += "]"
      @statistics_json = CGI::escape(@statistics_json)
      
      map = %Q{
        function() {
          emit({productId: this.product_id, productName: this.productName}, {quantity: this.quantity, purchasePrice: this.purchasePrice, retailPrice: this.retailPrice, profit: this.profit})
        }
      }
      reduce = %Q{
        function(key, values) {
          totalPrice = 0;
          values.forEach(function(value) {
             totalPrice += value.profit;
          });
          return totalPrice
        }
      }
      if params[:retailDateRang].present?
        dates = params[:retailDateRang].split(" - ")
        ps = Statistic.where(:retailDate => {"$gte" => dates[0],"$lte" => dates[1]}, :userinfo_id => current_user.userinfo.id.to_s).map_reduce(map, reduce).out(:inline => true)
      else
        ps = Statistic.map_reduce(map, reduce).out(:inline => true)
      end
      puts "//////=====#{ps}"
      @pie_chart_data = Hash.new
      ps.each {|pginfo| @pie_chart_data[pginfo["_id"]["productName"]] = format("%.2f", pginfo["value"])}
      puts "/////===--=-=-///#{@pie_chart_data}"
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def statistic_params
      params.require(:statistic).permit(:qrcode, :purchasePrice, :retailPrice, :quantity, :retailDate,
                                       :productName)
    end
end
