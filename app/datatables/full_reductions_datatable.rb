class FullReductionsDatatable
  delegate :params, :raw, :link_to, :number_to_currency, :edit_full_reduction_path, :to => :@view

  def initialize(view, current_user)
    @view = view
    @current_user = current_user
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: FullReduction.where(:userinfo_id => @current_user.userinfo.id, :preferential_way => @preferential_way).count,
      iTotalDisplayRecords: full_reductions.total_count,
      aaData: data
    }
  end

  private

    def data
      full_reductions.map do |full_reduction|
        case full_reduction.aasm_state
          when "noBeging" then labelState = "<span class='label label-lg label-info arrowed'>未开始</span>"
          when "beging" then labelState =  "<span class='label label-lg label-success'>正在进行</span>"
          when "end" then labelState = "<span class='label label-lg label-inverse arrowed-in'>已结束</span>"
        end
        action = "<div class='action-buttons'>"
        action += link_to "编辑", "##{edit_full_reduction_path(full_reduction)}", "data-url" => edit_full_reduction_path(full_reduction), :class => "btn btn-xs btn-primary"
        action += link_to "删除", full_reduction, :class => "btn btn-xs btn-danger", :method => :delete, :remote => true, :data => {:confirm => "您确定删除该活动吗？"}
        action += "</div>"
        [
            link_to(full_reduction.name, "##{edit_full_reduction_path(full_reduction)}", "data-url" => edit_full_reduction_path(full_reduction)),
            "#{full_reduction.startTimeShow} 至 #{full_reduction.endTimeShow}",
            labelState,
            action
        ]
      end
    end

    def full_reductions
      @full_reductions ||= fetch_full_reductions
    end

    def fetch_full_reductions
      @preferential_way = params[:preferential_way] || "1"
      full_reductions = params[:aasm_state].present? ? FullReduction.where(:aasm_state => params[:aasm_state]) : FullReduction
      full_reductions = full_reductions.where(:preferential_way => @preferential_way, :userinfo_id => @current_user.userinfo.id).order("#{sort_column} #{sort_direction}")
      full_reductions = full_reductions.page(page).per(per_page)
      searchText = params[:sSearch]
      if searchText.present?
        resultfull_reductions = full_reductions.where(:title => /#{searchText}/)
      else
        resultfull_reductions = full_reductions
      end
      resultfull_reductions
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