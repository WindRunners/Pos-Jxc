class CustomersDatatable
  delegate :params, :session, :raw, :link_to, :number_to_currency, :edit_coupon_path, :coupon_invalided_path, to: :@view

  def initialize(view, current_user)
    @view = view
    @current_user = current_user
  end

  def as_json(options = {})
    {
        sEcho: params[:sEcho].to_i,
        aaData: data ,#数据
        iTotalDisplayRecords: 20,
        iTotalRecords: data.length #总行数
    }
  end

  private

  def data
    customers.map do |customer|
      data_list = []
      data_list << customer['_id']
      data_list << customer['value']
      data_list
    end
  end

  def customers
    @integral_records ||= fetch_customers
  end

  def fetch_customers

    map = %Q{
        function(){
          emit(this.customer_id,1)
        }
      }

    reduce = %Q{

        function(key,values){
          return Array.sum(values);
        }
      }
    customer_list = Ordercompleted.where({'userinfo_id'=>@current_user['userinfo_id'],'workflow_state'=>'completed'}).map_reduce(map, reduce).out(inline: true)
    return  customer_list
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
