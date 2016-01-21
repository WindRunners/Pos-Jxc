class WinesDatatable
  delegate :params, :fa_icon, :link_to, :wines_path, :edit_wine_path, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
        data: data,
        recordsTotal: Wine.count,
        recordsFiltered: Wine.all.count
    }
  end

  private

  def data
    wines = []
    Wine.all.map do |record|
      wine = []
      wine << record.id
      wine << record.name
      wine << record.ad
      # product << (record.category.present? ? record.category.name : '')
      # product << link_to(fa_icon('info-circle lg'), products_path(record), class: 'label success round')
      # product << link_to(fa_icon('edit lg'), edit_products_path(record), class: 'label secondary round')
      # product << link_to(fa_icon('trash-o lg'), products_path(record), method: :delete, data: { confirm: 'Are you sure?' }, class: 'label alert round')
      wines << wine
    end
    wines
  end

  def my_search
    @filtered_wines = Wine.filter_product_code(params[:product_code]).filter_product_name(params[:product_name]).some_additional_scope.distinct.includes(:category)
  end

  def sort_order_filter
    records = my_search.order("#{sort_column} #{sort_direction}")
    if params[:search][:value].present?
      records = records.where("PRODUCTS.CODE like :search or lower(PRODUCTS.NAME) like :search", search: "%#{params[:search][:value]}%")
    end
    records
  end

  def display_on_page
    sort_order_filter.page(page).per(per_page)
  end

  def page
    params[:start].to_i/per_page + 1
  end

  def per_page
    params[:length].to_i > 0 ? params[:length].to_i : 10
  end

  def sort_column
    columns = %w[id name ad]
    columns[params[:order][:'0'][:column].to_i]
  end

  def sort_direction
    params[:order][:'0'][:dir] == "desc" ? "desc" : "asc"
  end
end