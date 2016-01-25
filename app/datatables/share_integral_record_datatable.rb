class ShareIntegralRecordDatatable
  delegate :params, :session, :raw, :link_to, :number_to_currency, :edit_coupon_path, :coupon_invalided_path, to: :@view

  def initialize(view, current_user)
    @view = view
    @current_user = current_user
  end

  def as_json(options = {})
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: ShareIntegralRecord.all.count, #总行数
        iTotalDisplayRecords: integral_records.total_count,
        aaData: data #数据
    }
  end

  private

  def data
    integral_records.map do |integral_record|

      data_list = []
      data_list << integral_record.shared_customer_id
      data_list << integral_record.register_customer_id
      data_list << integral_record.is_confirm
      data_list << integral_record.source
      data_list
    end
  end

  def integral_records
    @integral_records ||= fetch_integral_records
  end

  def fetch_integral_records

    map = %Q{
        function(){
          emit(this.store_id,1)
        }
      }

    reduce = %Q{

        function(key,values){
          return Array.sum(values);
        }
      }

    result_integral_records = ShareIntegralRecord.all.page(page).per(per_page)
    result_integral_records
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
