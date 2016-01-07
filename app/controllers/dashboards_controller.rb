class DashboardsController < ApplicationController

  include DashboardsHelper

  def index

  end


  def store_order_data

    data = DashboardsHelper.get_store_order_data(current_user)
    respond_to do |format|
      format.json { render json: data }
    end
  end

  def exposure_product_data

    data = DashboardsHelper.get_exposure_product_data(current_user)
    respond_to do |format|
      format.json { render json: data }
    end
  end


  def sale_product_data

    data = DashboardsHelper.get_sale_product_data(current_user)
    respond_to do |format|
      format.json { render json: data }
    end
  end



end
