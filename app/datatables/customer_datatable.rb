class CustomerDatatable
  delegate :params, :raw, :link_to, :number_to_currency, :edit_coupon_path, :coupon_invalided_path, to: :@view

  def initialize(view, current_user)
    @view = view
    @current_user = current_user
  end

  def as_json(options = {})
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: Customer.all.count,
        iTotalDisplayRecords: customers.total_count,
        aaData: data
    }
  end

  private

  def data
    customers.map do |customer|

      [
          customer.name,
          customer.mobile,
          customer.integral,

      ]
    end
  end

  def customers
    @customers ||= fetch_customers
  end

  def fetch_customers


    customers = Customer.all
    #customers = customers.order("#{sort_column} #{sort_direction}")
    customers = customers.page(page).per(per_page)
    # if params[:sSearch].present?
    #   customers = customers.where(:mobile => params[:sSearch])
    # end
    customers
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[name mobile integral]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end