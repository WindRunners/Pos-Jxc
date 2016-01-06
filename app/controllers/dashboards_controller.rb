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

end
