class ProductTicketsController < ApplicationController
  before_action :set_product_ticket, only: [:show, :edit, :update, :destroy]
  skip_before_action :authenticate_user!, only: [:register, :share_time_check, :share]

  # GET /product_tickets
  # GET /product_tickets.json
  def index
    @product_tickets = ProductTicket.all
  end

  # GET /product_tickets/1
  # GET /product_tickets/1.json
  def show
  end

  # GET /product_tickets/new
  def new
    @product_ticket = ProductTicket.new
  end

  # GET /product_tickets/1/edit
  def edit
  end

  # POST /product_tickets
  # POST /product_tickets.json
  def create
    @product_ticket = ProductTicket.new(product_ticket_params)
    @product_ticket.customer_ids= params[:product_ticket]['customer_ids'].split(",")
    @product_ticket.userinfo = current_user.userinfo
    respond_to do |format|
      if @product_ticket.save
        format.js { render_js product_tickets_path, 'Product ticket was successfully created.' }
        # format.html { redirect_to @product_ticket, notice: 'Product ticket was successfully created.' }
        format.json { render :show, status: :created, location: @product_ticket }
      else
        format.html { render :new }
        format.json { render json: @product_ticket.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /product_tickets/1
  # PATCH/PUT /product_tickets/1.json
  def update
    respond_to do |format|
      if @product_ticket.update(product_ticket_params)
        format.js { render_js product_tickets_path, 'Product ticket was successfully updated.' }
        # format.html { redirect_to @product_ticket, notice: 'Product ticket was successfully updated.' }
        format.json { render :show, status: :ok, location: @product_ticket }
      else
        format.html { render :edit }
        format.json { render json: @product_ticket.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /product_tickets/1
  # DELETE /product_tickets/1.json
  def destroy
    @product_ticket.destroy
    @product_ticket.card_bags.destroy
    respond_to do |format|
      format.js { render_js product_tickets_path, 'Product ticket was successfully destroyed.' }
      format.html { redirect_to product_tickets_url, notice: 'Product ticket was successfully destroyed.' }
      format.json { head :no_content }
    end
  end


  def customer_add
    product_ticket = ProductTicket.find(params[:product_ticket_id])
    product_ticket.customer_ids.push(params[:customer_id])
    product_ticket.save
    data = {}
    if product_ticket.save
      data['flag'] = 1
      data['message'] = '审核成功！'
    else
      data['flag'] = 0
      data['message'] = '审核失败！'
    end
    respond_to do |format|
      format.json { render json: data }
    end
  end

  def customer_reduce


    product_ticket = ProductTicket.find(params[:product_ticket_id])
    product_ticket.customer_ids.delete(params[:customer_id])
    data = {}
    if product_ticket.save
      data['flag'] = 1
      data['message'] = '审核成功！'
    else
      data['flag'] = 0
      data['message'] = '审核失败！'
    end
    respond_to do |format|
      format.json { render json: data }
    end

  end


  def build_card_bag


    product_ticket = ProductTicket.find(params[:product_ticket_id])

    data ={}

    product_ticket_customer_init = ProductTicketCustomerInit.where({:product_ticket_id => params[:product_ticket_id]})
    if product_ticket_customer_init.count == 0
      data = {:flag=>0,:message=>'发布失败，请导入酒劵会员！'}
    else

      product_ticket_customer_init.each do |ticket_customer|
        begin

          card_bag = product_ticket.card_bags.build()
          card_bag.customer_id = ticket_customer.customer_id
          card_bag.start_date = product_ticket.start_date
          card_bag.end_date = product_ticket.end_date
          card_bag.source = 0
          card_bag.save

          ticket_customer.destroy #移除酒劵初始化会员，历史记录转移超卡包中
        rescue Exception =>e
          Rails.logger.info "发布酒劵出错#{e.message}"
        end
      end
      product_ticket.status = 1

      if product_ticket.save
        data['flag'] = 1
        data['message'] = '发布成功！'
      else
        data['flag'] = 0
        data['message'] = '发布失败！'
      end
    end

    respond_to do |format|
      format.json { render json: data }
    end
  end

  def share
    @product_ticket = ProductTicket.find(params[:product_ticket_id])
    @shared_customer_id = "568bd0b0af484356f300333c"
    render :layout => false
  end

  def register
    data = {}
    product_ticket = ProductTicket.find(params[:product_ticket_id])
    customer = Customer.find_by_mobile(params[:mobile])
    if customer.present?
      data['flag'] = 0
      data['message'] = '该用户已注册！'
    else
      customer = Customer.new(:mobile => params[:mobile])
      if customer.save
        share_integral_record = product_ticket.share_integral_records.build();
        share_integral_record['shared_customer_id'] = params[:shared_customer_id]
        share_integral_record['register_customer_id'] = customer.id
        share_integral_record['is_confirm'] = 0
        share_integral_record.save
        data['flag'] = 1
        data['message'] = '注册成功！'

      else
        data['flag'] = -1
        data['message'] = '注册失败！'
      end
    end
    respond_to do |format|
      format.json { render json: data }
    end
  end


  def share_log_init

  end


  def share_log

      respond_to do |format|
        format.html
        format.json { render json: ShareIntegralRecordDatatable.new(view_context, current_user)}
      end
  end


  def customers_import

    @product_ticket = ProductTicket.find(params[:product_ticket_id])
  end

  def get_customers

    respond_to do |format|
      format.html
      format.json { render json: CustomersDatatable.new(view_context, current_user)}
    end
  end




  private
  # Use callbacks to share common setup or constraints between actions.
  def set_product_ticket
    @product_ticket = ProductTicket.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def product_ticket_params
    params.require(:product_ticket).permit(:title, :start_date, :end_date, :product_id, :status, :desc, :rule_content, :logo)
  end
end
