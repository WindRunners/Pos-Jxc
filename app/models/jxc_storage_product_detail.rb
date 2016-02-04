class JxcStorageProductDetail
  ##进销存 - 仓库&商品 详情
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic

  field :unit, type: String    #基本单位
  field :cost_price, type: BigDecimal, default: 0.00    #成本价
  field :retail_price, type: BigDecimal, default: 0.00  #零售价
  field :pack_spec, type: Integer, default: 0           #装箱规格
  field :count, type: Integer, default: 0    #商品数量
  field :amount, type: BigDecimal, default: 0.00 #库存金额
  field :virtual_count, type: Integer   #虚拟数量

  field :resource_product_id, type: String   #库存商品ID（ActiveResource Object）
  field :mobile_category_id, type: String   #商品分类ID（ActiveResource Object）

  belongs_to :jxc_storage   #详情信息 所属的仓库
  # belongs_to :product  #每条详情信息 包含一个商品
  belongs_to :classify_standard, class_name: 'JxcProductClassifyStandard' #商品根据收益分等级

  scope :by_storage, -> (storage_id){
    where(:jxc_storage_id => storage_id) if storage_id.present?
  }

  #计算库存金额
  def calcInventoryAmount(cost_price,count)
    amount = (cost_price.to_d * count.to_d).round(2)
  end

  #计算成本价
  def calcCostPrice(amount,count)
    if count == 0
      cost_price = 0.00
    else
      cost_price = (amount.to_d / count.to_d).round(2)
    end
  end

  #根据商品毛利，设置商品等级
  def classifyProductsByGrossProfit
    standardArray = JxcProductClassifyStandard.all.order_by(:standard => :asc)   #毛利分类标准数组
    grossProfit = (self.retail_price / self.cost_price - 1) * 100   #毛利，多少个百分点

    standardArray.each do |standardInfo|
      if grossProfit >= standardInfo.standard
        self.classify_standard = standardInfo
      end
    end

  end

  # 查询商品信息
  def product
    begin
      @product = Warehouse::Product.find(self.resource_product_id)
    rescue
      @product = nil
    end
  end

  #查询商品分类信息
  def mobile_category
    @mobile_category = Warehouse::MobileCategory.find(self.mobile_category_id)
  end

end
