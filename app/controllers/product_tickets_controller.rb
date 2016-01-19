class ProductTicketsController < ApplicationController
  before_action :set_product_ticket, only: [:show, :edit, :update, :destroy]

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
    binding.pry
    product_ticket = ProductTicket.find(params[:product_ticket_id])
    product_ticket.customer_ids.each do |customer_id|
      begin
        card_bag = product_ticket.card_bags.build()
        card_bag.customer_id = customer_id
        card_bag.source = 0
        card_bag.save
      rescue
      end
    end
    data ={}
    if product_ticket.save
      data['flag'] = 1
      data['message'] = '发布成功！'
    else
      data['flag'] = 0
      data['message'] = '发布失败！'
    end
    respond_to do |format|
      format.json { render json: data }
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
