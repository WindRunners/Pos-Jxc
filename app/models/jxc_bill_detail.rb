class JxcBillDetail
  ##单据商品详情
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic

  field :unit, type: String #计量单位
  field :pack_spec, type: Integer, default:0 #装箱规格
  field :package_count, type: Integer, default:0 #箱数
  field :count, type: Integer, default:0 #基本数量

  field :price, type: BigDecimal, default:0.00  #单价
  field :retail_price, type: BigDecimal, default:0.00 #零售单价
  field :amount, type: BigDecimal, default:0.00 #金额
  field :remark, type: String #备注

  ## 进销存属性
  belongs_to :product, foreign_key: :product_id #所属商品
  belongs_to :jxc_storage, foreign_key: :storage_id #仓库
  belongs_to :jxc_contacts_unit, foreign_key: :unit_id #所属供应商 | 客户

  belongs_to :jxc_purchase_order, foreign_key: :purchase_order_id #采购订单
  belongs_to :jxc_purchase_stock_in_bill, foreign_key: :purchase_in_bill_id #采购入库单
  belongs_to :jxc_purchase_returns_bill, foreign_key: :purchase_returns_bill_id #采购退货单

  belongs_to :jxc_sell_order, foreign_key: :sell_order_id #销售订单
  belongs_to :jxc_sell_stock_out_bill, foreign_key: :sell_out_bill_id #销售出库单
  belongs_to :jxc_sell_returns_bill, foreign_key: :sell_returns_bill_id #销售退货单

  belongs_to :jxc_other_stock_in_bill, foreign_key: :other_in_bill_id #其他入库单
  belongs_to :jxc_other_stock_out_bill, foreign_key: :other_out_bill_id #其他出库单

  belongs_to :jxc_stock_count_bill, foreign_key: :stock_count_bill_id #盘点单
  belongs_to :jxc_stock_overflow_bill, foreign_key: :stock_overflow_bill_id #报溢单
  belongs_to :jxc_stock_reduce_bill, foreign_key: :stock_reduce_bill_id #报损单
  belongs_to :jxc_entering_stock, foreign_key: :entering_stock_id #期初库存录入

  belongs_to :jxc_cost_adjust_bill, foreign_key: :cost_adjust_bill_id #成本调整单

  has_many :traceabilities #产品溯源条码

  #计算商品金额
  def calculate_amount(price,count)
    total_amount = (price.to_d * count.to_d).round(2)
  end

  #计算商品打折后的金额
  def calculate_discount_amount(price,count,discount)
    total_amount = (price.to_d * count.to_d * (discount.to_d/100)).round(2)
  end


  #计算 未到货/未发货 数量
  def calc_other_count(count,have_done_count)
    other_count = (count.to_d - have_done_count.to_d).round(2) #(未到货/未发货)数量 = 总数 - 已(收货/到货)数
  end

  #获取
  def self.getProduct(product_id)
    @product=Product.find_by(:id=>product_id)
  end

  #获取仓库信息
  def self.getStock(stock_id)
    JxcStorage.find_by(:id=>stock_id)
  end

end
