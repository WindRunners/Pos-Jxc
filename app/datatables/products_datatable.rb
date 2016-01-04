class ProductsDatatable
  delegate :params, :raw, :link_to, :number_to_currency, :best_in_place, to: :@view

  def initialize(view, current_user)
    @view = view
    @current_user = current_user
  end

  def as_json(options = {})
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: Product.shop(@current_user).count,
        iTotalDisplayRecords: products.total_count,
        aaData: data
    }
  end

  private

  def data
    products.map do |product|
      [
          raw("<img src='#{product.avatar}' width='60px' height='60px'/>&nbsp;&nbsp;&nbsp;&nbsp;") + link_to(product.title, @view.userinfo_product_preview_path(@current_user.userinfo, product), :target => '_blank'),
          best_in_place(product, :price, :display_with => :number_to_currency, :helper_options => {unit: '￥'}),
          best_in_place(product, :stock),
          product.sale_count,
          product.created_at.to_s,
          best_in_place(product, :num),
          raw("<div class='hidden-sm hidden-xs action-buttons'><a class='btn btn-xs btn-info' data-url='#{@view.product_path(product)}' href='##{@view.product_path(product)}'><i class='ace-icon fa fa-info bigger-130'></i></a></div>")
      ]
    end
  end

  def products
    @products ||= fetch_products
  end

  def fetch_products
    state = params[:state] || 'online'
    category_id = params[:category_id]

    case state
      when 'online', 'offline'
        products = Product.shop(@current_user).where(state: State.find_by(value:state))
      when 'restocking'
        products = Product.shop(@current_user).and(state: State.find_by(value:'online')).and(stock:0)
      when 'alarm'
        products = Product.shop(@current_user).where(state: State.find_by(value:'online')).for_js("this.stock <= this.alarm_stock ")
    end

    products = products.order("#{sort_column} #{sort_direction}")
    products = products.page(page).per(per_page)
    searchText = params[:sSearch]
    if searchText.present?
      products = products.where({:title => /#{searchText}/})
    end

    products = products.where(mobile_category_id:category_id) if category_id.present?

    products
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 25
  end

  def sort_column
    columns = %w[title price stock sale_count created_at num]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end

end