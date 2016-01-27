class ProductTicketCustomerInitDatatable
  delegate :params, :session, :raw, :link_to, :number_to_currency, :edit_coupon_path, :coupon_invalided_path, to: :@view

  def initialize(view, current_user,product_ticket)
    @view = view
    @current_user = current_user
    @product_ticket = product_ticket
  end

  def as_json(options = {})
    {
        sEcho: params[:sEcho].to_i,
        aaData: data ,#数据
        iTotalDisplayRecords: get_data_list.total_count,
        iTotalRecords: ProductTicketCustomerInit.where({'product_ticket_id' => @product_ticket.id}).count #总行数
    }
  end

  private

  def data
    get_data_list.map do |record|
        rows = []
        rows << record['mobile']
        rows << "<a class=\"btn btn-primary btn-sm\" href=\"javascript:remove('#{record.id.to_s}')\">移除</a>"
        rows
    end
  end

  def get_data_list
    @data_list ||= fetch_data_list
  end

  def fetch_data_list

    search_where = {}
    search_where['product_ticket_id'] = @product_ticket.id
    searchText = params[:sSearch]
    if searchText.present?
      search_where['mobile'] = /#{searchText}/
    end
    return ProductTicketCustomerInit.where(search_where).page(page).per(per_page)
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[title price stock sale_count created_at num]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end

end
