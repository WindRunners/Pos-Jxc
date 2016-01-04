class UserIntegralsDatatable
  delegate :params, :raw, :link_to, :number_to_currency, :edit_coupon_path, :coupon_invalided_path, to: :@view

  def initialize(view, current_user)
    @view = view
    @current_user = current_user
  end

  def as_json(options = {})
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: UserIntegral.count,
        iTotalDisplayRecords: integrals.total_count,
        aaData: data
    }
  end

  private

  def data
    integrals.map do |integral|

      [
          integral.integral,
          integral.state_show_str,
          integral.type_show_str,
          integral.integral_date.strftime('%Y-%m-%d %H:%M:%S').to_s,
          # link_to('显示',"##{user_integral_path(integral)}", "data-url" => user_integral_path(integral))
          raw("<div class='hidden-sm hidden-xs action-buttons'><a class='btn btn-xs btn-info' data-url='#{@view.user_integral_path(integral)}' href='##{@view.user_integral_path(integral)}'>显示</a></div>")

      ]
    end
  end

  def integrals
    @integrals ||= fetch_integrals
  end

  def fetch_integrals

    if params[:state]=="zc"
      state_to_i=2
    elsif params[:state]==1
      state_to_i=1
    else
      state_to_i=1
    end

    integrals = params[:state].present? ? UserIntegral.where(:state =>  state_to_i) : UserIntegral
    integrals = integrals.where(:userinfo_id=>@current_user.userinfo_id,:state =>  state_to_i)
    integrals = integrals.order("#{sort_column} #{sort_direction}")
    integrals = integrals.page(page).per(per_page)
    if params[:sSearch].present?
      integrals = integrals.where(:integral => /#{searchText}/)
    end
    integrals
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