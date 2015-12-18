class PromotionDiscountsDatatable
  delegate :params, :raw, :link_to, :number_to_currency, :edit_promotion_discount_path, to: :@view

  def initialize(view, current_user)
    @view = view
    @current_user = current_user
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: PromotionDiscount.where(:userinfo_id => @current_user.userinfo.id, :type => @type).count,
      iTotalDisplayRecords: promotion_discounts.total_count,
      aaData: data
    }
  end

  private

    def data
      promotion_discounts.map do |promotion_discount|
        case promotion_discount.aasm_state
          when "noBeging" then labelState = "<span class='label label-lg label-info arrowed'>未开始</span>"
          when "beging" then labelState =  "<span class='label label-lg label-success'>正在进行</span>"
          when "end" then labelState = "<span class='label label-lg label-inverse arrowed-in'>已结束</span>"
        end
        
        action = "<div class='action-buttons'>"
        action += link_to "编辑", "##{edit_promotion_discount_path(promotion_discount)}", "data-url" => edit_promotion_discount_path(promotion_discount), :class => "btn btn-xs btn-primary"
        action += link_to "删除", promotion_discount, :class => "btn btn-xs btn-danger", :method => :delete, :remote => true, :data => {:confirm => "您确定删除该活动吗？"}
        action += "</div>"
        [
            link_to(promotion_discount.title, "##{edit_promotion_discount_path(promotion_discount)}", "data-url" => edit_promotion_discount_path(promotion_discount)),
            "#{promotion_discount.startTimeShow} 至 #{promotion_discount.endTimeShow}",
            labelState,
            action
        ]
      end
    end

    def promotion_discounts
      @promotion_discounts ||= fetch_promotion_discounts
    end

    def fetch_promotion_discounts
      @type = params[:type] || "0"
      promotion_discounts = params[:aasm_state].present? ? PromotionDiscount.where(:aasm_state => params[:aasm_state]) : PromotionDiscount
      promotion_discounts = promotion_discounts.where(:type => @type, :userinfo_id => @current_user.userinfo.id).order("#{sort_column} #{sort_direction}")
      promotion_discounts = promotion_discounts.page(page).per(per_page)
      searchText = params[:sSearch]
      if searchText.present?
        resultpromotion_discounts = promotion_discounts.where(:title => /#{searchText}/)
      else
        resultpromotion_discounts = promotion_discounts
      end
      resultpromotion_discounts
    end

    def page
      params[:iDisplayStart].to_i / per_page + 1
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