class ProductTicketCustomerInitsController < ApplicationController
  before_action :set_product_ticket_customer_init, only: [:show, :edit, :update, :destroy,:remove]

  # GET /product_ticket_customer_inits
  # GET /product_ticket_customer_inits.json
  def index

    set_product_ticket
    @product_ticket_customer_init = ProductTicketCustomerInit.new
    @product_ticket_customer_init.product_ticket = @product_ticket
    respond_to do |format|
      format.html
      format.json { render json: ProductTicketCustomerInitDatatable.new(view_context, current_user,@product_ticket) }
    end
  end

  # GET /product_ticket_customer_inits/1
  # GET /product_ticket_customer_inits/1.json
  def show

  end

  # GET /product_ticket_customer_inits/new
  def new
    set_product_ticket
    @product_ticket_customer_init = ProductTicketCustomerInit.new
  end

  # GET /product_ticket_customer_inits/1/edit
  def edit
  end

  # POST /product_ticket_customer_inits
  # POST /product_ticket_customer_inits.json
  def create

    set_product_ticket
    @product_ticket_customer_init = ProductTicketCustomerInit.new(product_ticket_customer_init_params)
    @product_ticket_customer_init.product_ticket = @product_ticket

    respond_to do |format|

      begin

        if @product_ticket_customer_init.save
          format.json { render json: get_render_json(1,nil,'') }
        else
          format.json { render json: get_render_json(0,@product_ticket_customer_init.errors.messages,nil) }
        end
      rescue Exception => e
        p e.message
      end


    end
  end

  # PATCH/PUT /product_ticket_customer_inits/1
  # PATCH/PUT /product_ticket_customer_inits/1.json
  def update

    set_product_ticket

    respond_to do |format|
      if @product_ticket_customer_init.update(product_ticket_customer_init_params)
        format.json { render json: get_render_json(1,nil,product_ticket_product_ticket_customer_inits_path(@product_ticket)) }
      else
        format.json { render json: get_render_json(0,@product_ticket_customer_init.errors.messages,nil) }
      end
    end
  end

  # DELETE /product_ticket_customer_inits/1
  # DELETE /product_ticket_customer_inits/1.json
  def destroy

    @product_ticket_customer_init.destroy
    respond_to do |format|
      # format.html { redirect_to product_ticket_customer_inits_url, notice: 'Product ticket customer init was successfully destroyed.' }
      format.json { render json: {:flag => 1,:msg => "移除成功！"}}
    end
  end


  def remove

    @product_ticket_customer_init.destroy
    respond_to do |format|
      # format.html { redirect_to product_ticket_customer_inits_url, notice: 'Product ticket customer init was successfully destroyed.' }
      format.json { render json: {:flag => 1,:msg => "移除成功！"}}
    end
  end


  def import_customer

    set_product_ticket

    userinfo_id = current_user()['userinfo_id']

    start_date = params[:start_date]
    end_date = params[:end_date]
    # start_date = "2015/12/23"
    # end_date = "2016/01/30"

    # days = days_between(start_date, end_date)
    js_pd = get_import_date_str(start_date,end_date,userinfo_id)
    wherejs = %Q{
        function(){
          var count = 0;
          var obj = this;
          var getcount = function(year,month,day,userinfo){

              var count_inner = 0;
              if(obj[year] == undefined) return count_inner;
              if(obj[year][month] == undefined) return count_inner;
              if(obj[year][month][day] == undefined) return count_inner;
              if(obj[year][month][day][userinfo] == undefined) return count_inner;
              return obj[year][month][day][userinfo];
          };
          #{js_pd}
          return count >= 1;
        }
    }

    count = CustomerOrderStatic.where({:userinfo_ids => userinfo_id.to_s}).for_js(wherejs).count()
    Rails.logger.info "导入会员数量：#{count}"

    rows = 0

    CustomerOrderStatic.where({:userinfo_ids => userinfo_id.to_s}).for_js(wherejs).each do |customerOrderStatic|

      next if ProductTicketCustomerInit.where({:customer_id => customerOrderStatic.customer_id}).count>0

      rows+=1
      product_ticket_customer_init = ProductTicketCustomerInit.new
      product_ticket_customer_init.product_ticket = @product_ticket.id
      product_ticket_customer_init.customer_id = customerOrderStatic.customer_id
      product_ticket_customer_init.mobile = customerOrderStatic.mobile
      product_ticket_customer_init.save
    end

    respond_to do |format|
      format.json { render json: {:flag =>1,:msg => "导入成功#{rows}条记录！"} }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product_ticket_customer_init
      @product_ticket_customer_init = ProductTicketCustomerInit.find(params[:id])
    end

    # 设置导入包
    def set_product_ticket
      @product_ticket = ProductTicket.find(params[:product_ticket_id])
    end


    # Never trust parameters from the scary internet, only allow the white list through.
    def product_ticket_customer_init_params
      params.require(:product_ticket_customer_init).permit(:mobile, :customer_ids)
    end


    def get_import_date_str(start_date,end_date,userinfo_id)

      days =  days_between(start_date,end_date)
      startDate = Date.parse(start_date)

      str_array = []
      for i in 0..days
        nowDate = startDate+i
        str_array << "count += getcount(#{nowDate.strftime("'%Y','%m','%d'")},'#{userinfo_id}')"
      end
      str_array.join(";")+";"
    end

    def days_between(date1, date2)
      d1 = Date.parse(date1)
      d2 = Date.parse(date2)
      (d2 - d1).to_i
    end

end
