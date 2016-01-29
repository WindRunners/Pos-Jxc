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

      queryInfo = JxcStorageProductDetail.by_storage(storage_id).where(:mobile_category_id => category_id).order_by(:created_at => :desc)
      inventoryInfo = queryInfo.page(page).per(rows)
      inventoryInfo.each do |inventory|
        product = inventory.product
        inventory[:title] = product.title
        inventory[:brand] = product.brand
        inventory[:specification] = product.specification

        inventory_list << inventory
      end

      render json:{'total':queryInfo.count,'rows':inventory_list}
    else
      render json:{'total':0,'rows':[]}
    end
  end

  #库存详情
  def inventory_detail
  end

  #查询库存变更日志
  def checkInventoryChangeLog

    storage_id = params[:storage_id]
    product_id = params[:product_id]
    log_param = params[:searchParam] || '' #检索日志的条件

    page = params[:page]
    rows = params[:rows]

    logList = []

    if storage_id.present? && product_id.present?
      query = JxcStorageJournal.includes(:jxc_storage,:user).where(:jxc_storage_id => storage_id,:resource_product_id => product_id,:bill_no => /#{log_param}/).order_by(:created_at => :desc)

      _logList = query.page(page).per(rows)

      _logList.each do |log|
        store = log.jxc_storage
        product = log.product
        staff = log.user

        log[:storage_title] = store.present? ? store.storage_name : ''
        log[:product_title] = product.present? ? product.title : ''
        # log[:unit] = product.present? ? product.unit : ''
        log[:staff_name] = staff.present? ? staff.name : ''

        logList << log
      end

      render json:{'total':query.count,'rows':logList}
    else
      render json:{'total':0,'rows':[]}
    end

  end

end
