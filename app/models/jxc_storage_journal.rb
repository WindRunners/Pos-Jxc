class JxcStorageJournal
  ## 进销存 - 仓库商品流水明细
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic

  field :bill_no, type: String #产生仓库商品流水的单据编号
  field :bill_status, type: String #单据状态
  field :bill_type, type: String #单据类型
  field :bill_create_date, type: String #单据创建时间
  field :count, type: Integer #商品数量
  field :price, type: BigDecimal, default: 0.00 #成本价
  field :amount, type: BigDecimal, default: 0.00 #成本金额
  field :op_type, type: String #操作类型（0:入库 1:出库 2:报损 3:报溢 4:红冲 5:成本调整）
  field :previous_count, type: Integer #变动前的数量 （单据审核前）
  field :after_count, type: Integer #变动后的数量 （单据审核后）
  field :status, type: String, default: '0' #该条记录状态 （0：正常 | -1：作废）
  field :remark, type: String #备注

  field :resource_product_id, type: String  #库存变更日志 包含的商品信息(ActiveResource Object)

  belongs_to :jxc_storage #流水明细所属仓库
  # belongs_to :product #流水明细包含的商品
  belongs_to :user #经手人

  belongs_to :jxc_purchase_stock_in_bill #采购入库单
  belongs_to :jxc_sell_stock_out_bill #销售出库单
  belongs_to :jxc_purchase_returns_bill #采购退货单
  belongs_to :jxc_sell_returns_bill #销售退货单
  belongs_to :jxc_other_stock_in_bill #其他入库单
  belongs_to :jxc_other_stock_out_bill #其他出库单
  belongs_to :jxc_stock_overflow_bill #报溢单
  belongs_to :jxc_stock_reduce_bill #报损单
  belongs_to :jxc_stock_transfer_bill #调拨单
  belongs_to :jxc_cost_adjust_bill #成本调整单
  # belongs_to :jxc_entering_stock #期初库存录入
  belongs_to :jxc_stock_assign_bill #要货单

  # 定义获取 商品信息的方法
  def product
    @product = Warehouse::Product.find(self.resource_product_id)
  end
end
