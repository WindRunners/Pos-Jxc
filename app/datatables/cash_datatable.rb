class CashDatatable

  delegate :params, :raw, :link_to, :number_to_currency, :edit_coupon_path, :coupon_invalided_path, to: :@view

  def initialize(view, current_user)
    @view = view
    @current_user = current_user
  end

  def as_json(options = {})
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: Cash.count,
        iTotalDisplayRecords: cashes.total_count,
        aaData: data
    }
  end

  private

  def data
    cashes.map do |cash|

      [
          "-#{cash.cash}",
          cash.cash_state_to_s,
          cash.data_show
      ]
    end
  end

  def cashes
    @cashes ||= fetch_cashes
  end

  def fetch_cashes
    p '././././.',params[:aasm_state]
    cashes = params[:state].present? ? Cash.where(:userinfo_id => params[:aasm_state]) : Cash
    cashes = cashes.where(:userinfo_id=>@current_user.userinfo_id).order("#{sort_column} #{sort_direction}")
    cashes = cashes.page(page).per(per_page)
    if params[:sSearch].present?
      cashes = cashes.where(:cash => /#{searchText}/)
    end
    cashes
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