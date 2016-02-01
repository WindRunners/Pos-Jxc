class JxcCommonInfoController < ApplicationController
  ## 进销存 获取通用信息 Controller

  #进销存往来单位类别
  def getJxcUnitCategoriesInfo
    render json:JxcDictionary.where(:dic_desc => 'jxc_contacts_unit_category')
  end

  #供应商
  def getSuppliersInfo
    unitType = params[:unit_type]
    page = params[:page]
    rows = params[:rows]
    unit_param = params[:searchParam] || ''

    #如果传入单位类型ID为空，则查询所有供应商
    if unitType.blank?
      suppliersList = JxcContactsUnit.where(:unit_property => '0',:unit_name => /#{unit_param}/).page(page).per(rows)
      render json: {'total':JxcContactsUnit.where(:unit_property => '0',:unit_name => /#{unit_param}/).count,'rows':suppliersList}
    else
      suppliersList = JxcContactsUnit.where(unit_property:'0',unit_type:unitType,:unit_name => /#{unit_param}/).page(page).per(rows)
      render json: {'total':JxcContactsUnit.where(unit_property:'0',unit_type:unitType,:unit_name => /#{unit_param}/).count,'rows':suppliersList}
    end
  end

  #客户
  def getConsumersInfo
    unitType = params[:unit_type]
    page = params[:page]
    rows = params[:rows]
    unit_param = params[:searchParam] || ''

    #如果传入单位类型ID为空，则查询所有客户
    if unitType.blank?
      consumersList = JxcContactsUnit.where(unit_property:'1',:unit_name => /#{unit_param}/).page(page).per(rows)
      render json: {'total':JxcContactsUnit.where(unit_property:'1',:unit_name => /#{unit_param}/).count,'rows':consumersList}
    else
      consumersList = JxcContactsUnit.where(unit_property:'1',unit_type:unitType,:unit_name => /#{unit_param}/).page(page).per(rows)
      render json: {'total':JxcContactsUnit.where(unit_property:'1',unit_type:unitType,:unit_name => /#{unit_param}/).count,'rows':consumersList}
    end
  end

  #进销存仓库类型
  def getStorageTypesInfo
    render json: JxcDictionary.where(dic_desc:'storage_type')
  end

  #进销存仓库 （根据仓库类型查询）
  def getStorageInfo
    storage_type = params[:storage_type]
    page = params[:page]
    rows = params[:rows]
    store_param = params[:searchParam] || ''

    #如果传入仓库类型ID为空，则查询所有仓库
    if storage_type.blank?
      storageList = JxcStorage.where(:storage_name => /#{store_param}/).page(page).per(rows)
      render json:{'total':JxcStorage.where(:storage_name => /#{store_param}/).count,'rows':storageList}
    else
      storageList = JxcStorage.where(storage_type:storage_type,:storage_name => /#{store_param}/).page(page).per(rows)
      render json:{'total':JxcStorage.where(storage_type:storage_type,:storage_name => /#{store_param}/).count,'rows':storageList}
    end
  end

  #选择进销存仓库负责人
  def getJxcStorageAdmin
    search_param = params[:searchParam] || ''
    query = User.or({:name => /#{search_param}/},{:mobile => /#{search_param}/})
    render json: {'total':query.count,'rows':query.page(params[:page]).per(params[:rows])}
  end

  #进销存 账户信息
  # def getJxcAccountsInfo
  #   account_param = params[:searchParam] || ''
  #   accountsList = JxcAccount.where(:account_name => /#{account_param}/).page(params[:page]).per(params[:rows])
  #   render json: {'total':JxcAccount.where(:account_name => /#{account_param}/).count,'rows':accountsList}
  # end

  #部门
  # def getDepartmentsInfo
  #   render json: Department.all
  # end

  #经手人
  # def getHandlersInfo
  #   department_id = params[:department_id]
  #   page = params[:page]
  #   rows = params[:rows]
  #   handler_param = params[:searchParam] || ''
  #
  #   #如果传入部门ID为空，则查询所有职员信息
  #   if department_id.blank?
  #     handlerList = Staff.where(:name => /#{handler_param}/).page(page).per(rows)
  #     render json: {'total':Staff.where(:name => /#{handler_param}/).count,'rows':handlerList}
  #   else
  #     handlerList = Staff.where(department_id:department_id,:name => /#{handler_param}/).page(page).per(rows)
  #     render json: {'total':Staff.where(department_id:department_id,:name => /#{handler_param}/).count,'rows':handlerList}
  #   end
  # end

  #商品分类
  def getProductCategoriesInfo
    render json: Warehouse::MobileCategory.JYD
  end

  #商品
  def getProductsInfo
    category_id = params[:category_id]
    page = params[:page]
    rows = params[:rows]

    #如果传入分类ID为空，则查询所有商品
    if category_id.blank?
      productsList = Product.page(page).per(rows)
      render json: {'total':Product.count,'rows':productsList}
    else
      productsList = Category.find(category_id).products.page(page).per(rows)
      render json: {'total':Category.find(category_id).products.count,'rows':productsList}
    end
  end

  #单据明细
  def getBillDetailInfo
    # category_name = params[:category_name]  #商品分类
    storage_id = params[:storage_id]   #仓库
    product_param = params[:searchParam] || '' #检索商品条件

    page = params[:page]
    rows = params[:rows]

    detailList = []

    conditions = {
        category_id: params[:category_id],
        tag:'JYD',
        searchText: product_param,
        page: page,
        per: rows
    }

    # productList = Warehouse::Product.find(:all,params: {title: /#{product_param}/, mobile_category_name: category_name}, page: page, per: rows)
    productList = Warehouse::Product.where(conditions)
    productList.each do |product|

      begin
        storageInfo = JxcStorageProductDetail.find_by(:resource_product_id => product.id,:jxc_storage_id => storage_id)  #库存信息
      rescue
        storageInfo = nil
      end

      product = JSON.parse(product.to_json)

      if storageInfo.present?
        product[:cost_price] = storageInfo.cost_price
        product[:count] = storageInfo.count
        product[:amount] = storageInfo.amount
        product[:pack_spec] = storageInfo.pack_spec
      else
        product[:cost_price] = 0
        product[:count] = 0
        product[:amount] = 0
        product[:pack_spec] = 0
      end

      detailList << product
    end
    render json: {'total':productList.http_response['X-total'].to_i,'rows':detailList}

  end

  #商品
  def getProductsPageInfo #easyui
    category_id = params[:category_id]
    productsList = []
    if !category_id.blank?
      # productsList=Product.where(:category_id=>category_id);
      productsList = Category.find(category_id).products.page(params[:page]).per(params[:rows])
    end
    render json: {"total"=>Category.find(category_id).products.size,"rows"=>productsList}
  end

  #经手人
  # def getHandlersPageInfo #easyui
  #   department_id = params[:department_id]
  #   handlerList = []
  #   if !department_id.blank?
  #     handlerList = Staff.where(department_id:department_id).page(params[:page]).per(params[:rows])
  #   end
  #   render json: {"total"=>Staff.where(department_id:department_id).size,"rows"=>handlerList}
  # end

  #进销存仓库 （根据仓库类型）easyui
  def getStoragePageInfo
    p params[:storage_type]
    storage_type = params[:storage_type]
    storageList = []
    if !storage_type.nil?
      storageList = JxcStorage.where(storage_type:storage_type)
    end
    render json: {'total'=>JxcStorage.where(storage_type:storage_type).size,'rows'=>storageList}
  end

  #会计科目
  # def getAccountingItemsInfo
  #   render json: JxcAccountingItem.all
  # end

  #进销存往来单位类别
  def getJxcUnits
    render json:JxcContactsUnit.all
  end

  def getJxcDictionaryByDesc
    render json:JxcDictionary.where(:dic_desc => params[:desc])
  end
end
