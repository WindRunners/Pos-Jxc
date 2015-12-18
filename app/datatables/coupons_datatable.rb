class CouponsDatatable
  delegate :params, :raw, :link_to, :number_to_currency, :edit_coupon_path, :coupon_invalided_path, to: :@view

  def initialize(view, current_user)
    @view = view
    @current_user = current_user
  end

  def as_json(options = {})
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: Coupon.where(:userinfo_id => @current_user.userinfo.id).count,
        iTotalDisplayRecords: coupons.total_count,
        aaData: data
    }
  end

  private

    def data
      coupons.map do |coupon|
        useCount = Ordercompleted.where(:coupon_id => coupon.id.to_s, :userinfo_id => coupon.userinfo_id, :workflow_state => "completed").count
        if "invalided" == coupon.aasm_state
          action = "<button type='button' class='btn btn-xs' disable='true'>已失效</button>"
        else
          action = "<div class='action-buttons'>"
          #action += link_to "查看", coupon, :class => "btn btn-xs"
          action += link_to "编辑", "##{edit_coupon_path(coupon)}", "data-href" => edit_coupon_path(coupon), :class => "btn btn-xs btn-primary"
          action += link_to "使失效", "##{coupon_invalided_path(coupon)}", "data-href" => coupon_invalided_path(coupon), :class => "btn btn-xs btn-danger"
          action += "</div>"
        end
        [
            link_to(coupon.title, "invalided" == coupon.aasm_state ? "javascript:void(0)" : "##{edit_coupon_path(coupon)}", "data-href" => "invalided" == coupon.aasm_state ? "" : edit_coupon_path(coupon)),
            (coupon.value.present? ? number_to_currency(coupon.value, unit: '￥') : "" ) +
            ("0" == coupon.order_amount_way ? "" : raw("<br/><span class='font-grey'>最低消费: #{number_to_currency(coupon.order_amount, unit: '￥')}</span>")),
            ("0" == coupon.limit ? "不限张数" : "一人#{coupon.limit}张") + "<br/><span class='font-grey'>库存: #{coupon.quantity}</span>",
            "#{coupon.startTimeShow} 至 #{coupon.endTimeShow}",
            "#{coupon.customer_ids.size}/#{coupon.receive_count}",
            useCount,
            action
        ]
      end
    end

    def coupons
      @coupons ||= fetch_coupons
    end

    def fetch_coupons
      coupons = params[:aasm_state].present? ? Coupon.where(:aasm_state => params[:aasm_state]) : Coupon
      coupons = coupons.where(:userinfo_id => @current_user.userinfo.id).order("#{sort_column} #{sort_direction}")
      coupons = coupons.page(page).per(per_page)
      searchText = params[:sSearch]
      if searchText.present?
        resultCoupons = coupons.where(:title => /#{searchText}/)
      else
        resultCoupons = coupons
      end
      resultCoupons
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