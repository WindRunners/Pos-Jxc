class InventoryWarningProduct
  #库存预警商品 列表

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  include Mongoid::Multitenancy::Document

  tenant(:client)

  field :resource_product_id, type: String  #预警商品ID
  belongs_to :jxc_storage, foreign_key: :storage_id  #预警仓库

  field :current_inventory, type: Integer #当前库存
  field :inventory_warning_count, type: Integer #预警数量

  scope :by_storage, -> (storage_id){
    where(:storage_id => storage_id) if storage_id.present?
  }

  #添加库存预警商品
  def self.add_inventory_warning_product(product_id,storage_id,current_inventory,inventory_warning_count)

    begin
      @inventoryWarningProduct = InventoryWarningProduct.find_by(resource_product_id: product_id,storage_id: storage_id)
    rescue
      @inventoryWarningProduct = nil
    end

    if @inventoryWarningProduct.present?
      @inventoryWarningProduct.current_inventory = current_inventory
      @inventoryWarningProduct.inventory_warning_count = inventory_warning_count
    else
      @inventoryWarningProduct = InventoryWarningProduct.new
      @inventoryWarningProduct.resource_product_id = product_id
      @inventoryWarningProduct.storage_id = storage_id
      @inventoryWarningProduct.current_inventory = current_inventory
      @inventoryWarningProduct.inventory_warning_count = inventory_warning_count
      @inventoryWarningProduct.save
    end

  end

  #移除库存预警商品(商品补货后，移除预警)
  def self.remove_inventory_warning_product(product_id,storage_id)

    begin
      @inventoryWarningProduct = InventoryWarningProduct.find_by(resource_product_id: product_id,storage_id: storage_id)
    rescue
      @inventoryWarningProduct = nil
    end

    if @inventoryWarningProduct.present?
      @inventoryWarningProduct.destroy
    end

  end


  def product
    begin
      @product = Warehouse::Product.find(self.resource_product_id)
    rescue
      @product = nil
    end
  end

  def store
    begin
      @store = JxcStorage.find(self[:storage_id])
    rescue
      @store = nil
    end
  end

end
