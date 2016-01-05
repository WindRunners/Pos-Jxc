class CouponsDatatable
  delegate :params, :session, :raw, :link_to, :number_to_currency, :edit_coupon_path, :coupon_invalided_path, to: :@view

  def initialize(view, current_user)
    @view = view
    @current_user = current_user
    @operat = params[:operat]
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
        if @operat.blank?
          if "invalided" == coupon.aasm_state
            action = "<button type='button' class='btn btn-xs' disable='true'>已失效</button>"
          else
            action = "<div class='action-buttons'>"
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
              "#{coupon.receiveCustomerCount}/#{coupon.receive_count}",
              coupon.useCount,
              action
          ]
        else
          result = [
            coupon.title,
            coupon.quantity,
            coupon.value,
            coupon.limit,
            coupon.startTimeShow,
            coupon.endTimeShow,
            "0" == coupon.order_amount_way ? "无限制" : coupon.order_amount,
            "0" == coupon.use_goods ? "全店能用" : "指定商品"
          ]
          case @operat
            when "full_reduction_select_coupon" then
              couponIndex = session[:coupon_infos].index {|cinfo| cinfo["coupon_id"] == coupon.id.to_s}
              if couponIndex.present?
                result.push(raw("<input type='number' id='quantity_#{coupon.id}' value='#{session[:coupon_infos][couponIndex][:quantity.to_s]}' />"))
                result.push(raw("<button type='button' class='btn' disabled='true'>已参加</button>"))
              else
                result.push(raw("<input type='number' id='quantity_#{coupon.id}' value='' />"))
                result.push(raw("<button type='button' class='btn btn-primary' id='#{coupon.id}_attend' onclick='attendActivity(\"#{coupon.id}\", false, true)'>参加活动</button>"))
              end
            when "full_reduction_selected_coupon" then
              couponIndex = session[:coupon_infos].index {|cinfo| cinfo["coupon_id"] == coupon.id.to_s}
              result.push(raw("<input type='number' id='quantity_#{coupon.id}' value='#{session[:coupon_infos][couponIndex][:quantity.to_s]}' />"))
              result.push(raw("<button type='button' class='btn btn-primary' id='#{coupon.id}_cancel' onclick='cancelActivity(\"#{coupon.id}\", false, true)'>取消活动</button>"))
          end
        end
      end
    end

    def coupons
      @coupons ||= fetch_coupons
    end

    def fetch_coupons
      if @operat.present?
        case @operat
          when "full_reduction_select_coupon" then
            coupons = Coupon.where({:aasm_state => "beging", :userinfo_id => @current_user.userinfo.id, :quantity => {"$gt" => 0}})
          when "full_reduction_selected_coupon" then
            coupons = Coupon.where(:aasm_state => "beging", :userinfo_id => @current_user.userinfo.id, :id => {"$in" => session[:coupon_infos].map {|pinfo| pinfo["coupon_id"]}})
        end
      else
        coupons = params[:aasm_state].present? ? Coupon.where(:aasm_state => params[:aasm_state], :userinfo_id => @current_user.userinfo.id) : Coupon.where(:userinfo_id => @current_user.userinfo.id)
      end
      coupons = coupons.order("#{sort_column} #{sort_direction}")
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
