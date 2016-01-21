class JxcContactsUnitsController < ApplicationController
  before_action :set_jxc_contacts_unit, only: [:show, :edit, :update, :destroy]

  def index
    @jxc_contacts_units = JxcContactsUnit.includes(:department,:clerk).order_by(:created_at => :desc).page(params[:page]).per(10)
  end

  def show
  end

  def new
    @jxc_contacts_unit = JxcContactsUnit.new
  end

  def edit
  end

  def create
    @jxc_contacts_unit = JxcContactsUnit.new(jxc_contacts_unit_params)
    department_id = params[:jxc_contacts_unit][:department_id]
    clerk_id = params[:jxc_contacts_unit][:clerk_id]

    @jxc_contacts_unit.department_id = department_id
    @jxc_contacts_unit.clerk_id = clerk_id

    respond_to do |format|
      if @jxc_contacts_unit.save
        format.html { redirect_to jxc_contacts_units_path, notice: '进销存往来单位已成功创建.' }
        format.json { render :show, status: :created, location: @jxc_contacts_unit }
      else
        format.html { render :new }
        format.json { render json: @jxc_contacts_unit.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      department_id = params[:jxc_contacts_unit][:department_id]
      clerk_id = params[:jxc_contacts_unit][:clerk_id]

      @jxc_contacts_unit.department_id = department_id
      @jxc_contacts_unit.clerk_id = clerk_id

      if @jxc_contacts_unit.update(jxc_contacts_unit_params)
        format.html { redirect_to @jxc_contacts_unit, notice: '进销存往来单位已成功更新.' }
        format.json { render :show, status: :ok, location: @jxc_contacts_unit }
      else
        format.html { render :edit }
        format.json { render json: @jxc_contacts_unit.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @jxc_contacts_unit.destroy
    respond_to do |format|
      format.html { redirect_to jxc_contacts_units_url, notice: '进销存往来单位已经成功删除.' }
      format.json { head :no_content }
    end
  end

  private
  def set_jxc_contacts_unit
    @jxc_contacts_unit = JxcContactsUnit.find(params[:id])
  end

  def jxc_contacts_unit_params
    params.require(:jxc_contacts_unit).permit(
        :unit_name,:unit_property,:unit_type,:spell_code,:unit_address,:unit_code,:data_1,:data_2,:data_3,:data_4,
        :contact_name,:contact_call,:contact_mobile,:contact_fax,:contact_address,:contact_postcode,:contact_email,
        :legal_person,:registered_capital,:bank_info,:bank_account,:company_type,:tax_number,:business_range,:consumer_overview,
        :start_receivable,:start_payable,:total_receivable,:total_payable,:receivable_credit,:payable_credit,:receive_deadline,:payment_deadline
    )
  end
end
