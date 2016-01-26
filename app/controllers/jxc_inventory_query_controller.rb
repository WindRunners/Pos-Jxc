class JxcInventoryQueryController < ApplicationController

  #库存首页
  def inventory_index
  end

  #库存查询方法
  def inventory_query
    category_id = params[:category_id]
    storage_id = params[:storage_id]
    page = params[:page]
    rows = params[:rows]
    inventory_list = []

    if category_id.present?
      category = Category.find(category_id)
      query = JxcStorageProductDetail.by_storage(storage_id).includes(:product).where(:product_id.in => category.product_ids).order_by(:created_at => :desc)
      inventoryInfo = query.page(page).per(rows)
      inventoryInfo.each do |inventory|
        product_info = inventory.product
        inventory[:title] = product_info.title
        inventory[:brand] = product_info.brand
        inventory[:specification] = product_info.specification
        inventory_list << inventory
      end
      render json:{'total':query.count,'rows':inventory_list}
    else
      render json:{'total':0,'rows':[]}
    end
  end

  #库存详情
  def inventory_detail
  end

end
