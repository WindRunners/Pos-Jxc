class JxcTransferBillDetail
  #仓库调拨单 单据明细
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic

  field :unit, type: String                 #商品单位
  field :pack_spec, type: String            #商品装箱规格
  field :package_count, type: String        #箱数
  field :count, type: Integer               #数量

  field :cost_price, type: BigDecimal       #成本价
  field :transfer_price, type: BigDecimal   #调拨单价
  field :transfer_amount, type: BigDecimal  #调拨差额
  field :amount, type: BigDecimal           #小计
  field :remark, type: String               #备注

  field :resource_product_id, type: String  #单据明细 包含的商品信息ID ( ActiveResource Object )

  # belongs_to :product #单据明细 所包含的商品信息
  belongs_to :jxc_stock_transfer_bill, foreign_key: :stock_transfer_bill_id
  belongs_to :jxc_stock_assign_bill,  foreign_key: :stock_assign_bill_id

  has_and_belongs_to_many :transfer_out_stock, class_name: 'JxcStorage' #换出仓库
  has_and_belongs_to_many :transfer_in_stock, class_name: 'JxcStorage' #换入仓库

  has_and_belongs_to_many :assign_out_stock, class_name: 'JxcStorage' #总库
  has_and_belongs_to_many :assign_in_stock, class_name: 'JxcStorage'  #要货仓库

  has_many :traceabilities  #产品溯源条码

  #计算商品金额
  def calculate_amount(price,count)
    total_amount = (price.to_d * count.to_d).round(2)
  end

  #查询关联商品信息
  def product
    @product = Warehouse::Product.find(self.resource_product_id)
  end

  def assign_out_stock
    begin
      @assign_out_stock = JxcStorage.find(self.assign_out_stock_ids[0])
    rescue
      @assign_out_stock = nil
    end
    return @assign_out_stock
  end

  def assign_in_stock
    begin
      @assign_in_stock = JxcStorage.find(self.assign_in_stock_ids[0])
    rescue
      @assign_in_stock = nil
    end
    return @assign_in_stock
  end

end
