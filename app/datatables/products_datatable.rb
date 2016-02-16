class ProductsDatatable
  delegate :params, :session, :raw, :link_to, :number_to_currency, :best_in_place, to: :@view

  def initialize(view, current_user)
    @view = view
    @current_user = current_user
    @operat = params[:operat]
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
      if @operat.blank?
        [
            raw("<img src='#{product.avatar_url}' width='60px' height='60px'/>&nbsp;&nbsp;&nbsp;&nbsp;") + link_to(product.title, @view.userinfo_product_preview_path(@current_user.userinfo, product), :target => '_blank'),
            best_in_place(product, :price, :display_with => :number_to_currency, :helper_options => {unit: '￥'}),
            best_in_place(product, :stock),
            product.sale_count,
            product.created_at.to_s,
            best_in_place(product, :num),
            raw("<div class='hidden-sm hidden-xs action-buttons'><a class='btn btn-xs btn-info' data-url='#{@view.product_path(product)}' href='##{@view.product_path(product)}'><i class='ace-icon fa fa-info bigger-130'></i></a></div>")
        ]
      else
        result = [
          raw("<img src='#{product.avatar}' width='60px' height='60px'/>"),
          product.qrcode,
          product.title,
          format("%.2f", product.purchasePrice).to_f,
          format("%.2f", product.price).to_f,
          product.stock]
        case @operat
          when "promotion_select_product" then
            if '1' == params[:type]
              productIndex = session[:promotion_select_product_ids].index {|pinfo| pinfo["product_id"] == product.id.to_s}
              if productIndex.present?
                result.push(raw("<input type='number' id='quantity_#{product.id}' value='#{session[:promotion_select_product_ids][productIndex][:price.to_s]}' />"))
                result.push(raw("<button type='button' class='btn' disabled='true'>已参加</button>"))
              else
                result.push(raw("<input type='number' id='quantity_#{product.id}' value='' />"))
                result.push(raw("<button type='button' class='btn btn-primary' id='#{product.id}_attend' onclick='attendActivity(\"#{product.id}\", true)'>参加活动</button>"))
              end
            else
              if session[:promotion_select_product_ids].include?(product.id.to_s)
                result.push(raw("<button type='button' class='btn' disabled='true'>已参加</button>"))
              else
                result.push(raw("<button type='button' class='btn btn-primary' id='#{product.id}_attend' onclick='attendActivity(\"#{product.id}\", false)'>参加活动</button>"))
              end
            end
          when "promotion_selected_product" then
            if '1' == params[:type]
              productIndex = session[:promotion_select_product_ids].index {|pinfo| pinfo["product_id"] == product.id.to_s}
              result.push(raw("<input type='number' id='quantity_#{product.id}' value='#{session[:promotion_select_product_ids][productIndex][:price.to_s]}' />"))
              result.push(raw("<button type='button' class='btn btn-primary' id='#{product.id}_cancel' onclick='cancelActivity(\"#{product.id}\", true)'>取消参加</button>"))
            else
              result.push(raw("<button type='button' class='btn btn-primary' id='#{product.id}_cancel' onclick='cancelActivity(\"#{product.id}\", false)'>取消参加</button>"))
            end
          when "full_reduction_select_product" then
            if session[:participate_product_ids].include?(product.id.to_s)
              result.push(raw("<button type='button' class='btn'>已参加</button>"))
            else
              result.push(raw("<button type='button' class='btn btn-primary' id='#{product.id}_attend' onclick='attendActivity(\"#{product.id}\", false, false)'>参加活动</button>"))
            end
          when "full_reduction_selected_product" then
            result.push(raw("<button type='button' class='btn btn-primary' id='#{product.id}_cancel' onclick='cancelActivity(\"#{product.id}\", false, false)'>取消参加</button>"))
          when "full_reduction_gift_select_product" then
            productIndex = session[:gifts_product_ids].index {|pinfo| pinfo["product_id"] == product.id.to_s}
            if productIndex.present?
              result.push(raw("<input type='number' id='quantity_#{product.id}' value='#{session[:gifts_product_ids][productIndex][:quantity.to_s]}' />"))
              result.push(raw("<button type='button' class='btn' disabled='true'>已参加</button>"))
            else
              result.push(raw("<input type='number' id='quantity_#{product.id}' value='' />"))
              result.push(raw("<button type='button' class='btn btn-primary' id='gift_#{product.id}_attend' onclick='attendActivity(\"#{product.id}\", true, false)'>参加活动</button>"))
            end
          when "full_reduction_gift_selected_product" then
            productIndex = session[:gifts_product_ids].index {|pinfo| pinfo["product_id"] == product.id.to_s}
            result.push(raw("<input type='number' id='quantity_#{product.id}' value='#{session[:gifts_product_ids][productIndex][:quantity.to_s]}' />"))
            result.push(raw("<button type='button' class='btn btn-primary' id='gift_#{product.id}_cancel' onclick='cancelActivity(\"#{product.id}\", true, false)'>取消参加</button>"))
          when "coupon_selected_product" then
            result = [
              result[0],
              result[2],
              result[4],
              raw("<button type='button' class='btn btn-primary' id='#{product.id}_cancel' onclick='cancelActivity(\"#{product.id}\")'>删除</button>")
            ]
          when "coupon_select_product" then
            result = [
              result[0],
              result[2],
              result[4],
              result[5],
              raw("<button type='button' class='btn btn-primary' id='#{product.id}_attend' onclick='toogleActivity(\"#{product.id}\")'>选取</button>")
            ]
        end
        result
      end
    end
  end

  def products
    @products ||= fetch_products
  end

  def fetch_products
    state = params[:state] || 'online'
    category_id = params[:category_id]

    if @operat.blank?
      case state
        when 'online', 'offline'
          products = Product.shop(@current_user).where(state: State.find_by(value:state))
        when 'restocking'
          products = Product.shop(@current_user).and(state: State.online).and(stock:0)
        when 'alarm'
          products = Product.shop(@current_user).where(state: State.online).for_js("this.stock <= this.alarm_stock ")
      end
    else
      case @operat
        when "promotion_select_product" then
          products = Product.shop(@current_user).where(:state => State.online, :panic_price => 0)
        when "promotion_selected_product" then
          productIds = "0" == params[:type] ? session[:promotion_select_product_ids] : session[:promotion_select_product_ids].map {|pinfo| pinfo["product_id"]}
          products = Product.shop(@current_user).where(:id => {"$in" => productIds})
        when "full_reduction_select_product" then
          products = Product.shop(@current_user).where(:state => State.online, :full_reduction_id => nil)
        when "full_reduction_selected_product" then
          products = Product.shop(@current_user).where(:state => State.online, :id => {"$in" => session[:participate_product_ids]})
        when "full_reduction_gift_select_product" then
          products = Product.shop(@current_user).where(:state => State.online)
        when "full_reduction_gift_selected_product" then
          products = Product.shop(@current_user).where(:state => State.online, :id => {"$in" => session[:gifts_product_ids].map {|pinfo| pinfo["product_id"]}})
        when "coupon_selected_product" then
          products = Product.shop(@current_user).where(:state => State.online, :id => {"$in" => session[:select_product_ids]})
        when "coupon_select_product" then
          products = Product.shop(@current_user).where(:state => State.online, :coupon_id => nil, :id => {"$not" => {"$in" => session[:select_product_ids]}})
      end
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
