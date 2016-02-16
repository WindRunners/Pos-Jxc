class JxcStockCountBill < JxcBaseModel
  ## 进销存 盘点单
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  include Mongoid::Multitenancy::Document

  tenant(:client)

  field :bill_no, type: String            #单据编号
  field :customize_bill_no, type: String  #自定义单据编号
  field :check_date, type: DateTime       #盘点日期
  field :remark, type: String             #备注

  field :bill_status, type: String, default: '0'    #单据状态 ( -1:已作废 | 0:已创建 | 1:已预审 | 2:已最终确认 )

  belongs_to :jxc_storage, foreign_key: :storage_id   #盘点仓库
  has_and_belongs_to_many :handler, class_name:'User', foreign_key: :handler_id   #经手人
  has_and_belongs_to_many :bill_maker, class_name:'User', foreign_key: :maker_id #制单人

  has_many :jxc_bill_details  #单据商品明细
  has_one :jxc_stock_overflow_bill  #盘点单可能会生成一张 报溢单
  has_one :jxc_stock_reduce_bill    #盘点单可能会生成一张 报损单

  #生成单据编号
  def generate_bill_no
    random = ''
    6.times.each{
      random += rand(9).to_s
    }
    'PDD'+'-'+Time.now.strftime('%Y%m%d')+'-'+Time.now.strftime('%H%M%S')+'-'+random
  end


  #单据预审核
  def audit_in_advance(current_user)
    #处理结果
    result = {}
    result[:flag] = 0

    if self.bill_status == PDD_BillStatus_Create
      self.bill_status = PDD_BillStatus_PreAudit
      self.update

      result[:flag] = 1
      result[:msg] = '盘点单已预审'
    else
      result[:msg] = '单据当前状态无法审核!'
    end

    return result
  end


  #生成盈亏单
  def generate_pl_bill(current_user)
    #处理结果
    result = {}
    result[:flag] = 0

    overflow_bill = self.jxc_stock_overflow_bill
    reduce_bill = self.jxc_stock_reduce_bill

    if self.bill_status == PDD_BillStatus_PreAudit
      if overflow_bill.blank? && reduce_bill.blank?

        generate_profit_and_loss_bill(current_user)

        result[:flag] = '1'
        result[:msg] = '已生成盈亏单'
      else
        result[:msg] = '当前盘点单已生成盈亏单，不能重复生成!'
      end
    else
      result[:msg] = '单据当前状态无法生成盈亏单!'
    end

    return result
  end


  #最终确认
  def finally_confirm(current_user)
    #处理结果
    result = {}
    result[:flag] = 0

    overflow_bill = self.jxc_stock_overflow_bill
    reduce_bill = self.jxc_stock_reduce_bill

    if self.bill_status == PDD_BillStatus_PreAudit
      if overflow_bill.blank? && reduce_bill.blank?
        generate_profit_and_loss_bill(current_user)

        overflow_bill = self.jxc_stock_overflow_bill
        reduce_bill = self.jxc_stock_reduce_bill
      end

      if overflow_bill.present?
        overflow_bill.audit(current_user)
      end

      if reduce_bill.present?
        reduce_bill.audit(current_user)
      end

      self.bill_status = PDD_BillStatus_FinallyConfirm
      self.update

      result[:flag] = 1
      result[:msg] = '盘点单已成功确认，生成的报损单报溢单已成功转化库存。'
    else
      result[:msg] = '请先预审盘点单，再进行最终确认!'
    end

    return result
  end


  #单据作废
  def bill_invalid
    #处理结果
    result = {}
    result[:flag] = 0

    if self.bill_status == PDD_BillStatus_Create
      self.bill_status = PDD_BillStatus_Invalid
      self.update

      result[:flag] = 1
      result[:msg] = '盘点单已作废'
    else
      result[:msg] = '单据当前状态无法作废!'
    end

    return result
  end


  #生成报损单和报溢单
  def generate_profit_and_loss_bill(current_user)
    #单据明细
    billDetailArray = JxcBillDetail.where(stock_count_bill_id: self.id)

    #报溢单据明细
    overflowDetailArray = []
    #报损单据明细
    reduceDetailArray = []

    if billDetailArray.present?
      billDetailArray.each do |billDetail|
        if billDetail[:pl_count].to_d < 0
          reduceDetailArray << billDetail
        elsif billDetail[:pl_count].to_d > 0
          overflowDetailArray << billDetail
        end
      end
    end

    if overflowDetailArray.present?
      generate_overflow_bill(overflowDetailArray,current_user)
    end

    if reduceDetailArray.present?
      generate_reduce_bill(reduceDetailArray,current_user)
    end
  end

  #生成报溢单
  def generate_overflow_bill(overflowDetailArray,current_user)
    @jxc_stock_overflow_bill = JxcStockOverflowBill.new
    #报溢单编号
    @jxc_stock_overflow_bill.bill_no = @jxc_stock_overflow_bill.generate_bill_no
    #报溢仓库
    @jxc_stock_overflow_bill.jxc_storage = self.jxc_storage
    #经手人
    @jxc_stock_overflow_bill.handler << self.handler
    #制单人
    @jxc_stock_overflow_bill.bill_maker << current_user
    #报溢时间
    @jxc_stock_overflow_bill.overflow_date = self.check_date
    #备注
    @jxc_stock_overflow_bill.remark = '盘点生成，盘点单号:'+self.bill_no
    #生成报溢单的盘点单
    @jxc_stock_overflow_bill.jxc_stock_count_bill = self


    overflowDetailArray.each do |overflowDetail|
      tempBillDetail = JxcBillDetail.new

      tempBillDetail.price = overflowDetail.price
      tempBillDetail.count = overflowDetail[:pl_count]  #报溢数量
      tempBillDetail.amount = overflowDetail[:pl_amount]  #报溢金额

      tempBillDetail.resource_product_id = overflowDetail.resource_product_id
      tempBillDetail.unit = overflowDetail.unit

      tempBillDetail.jxc_storage = overflowDetail.jxc_storage
      tempBillDetail.stock_overflow_bill_id = @jxc_stock_overflow_bill.id

      tempBillDetail.save
    end

    @jxc_stock_overflow_bill.save
  end


  #生成报损单
  def generate_reduce_bill(reduceDetailArray,current_user)
    @jxc_stock_reduce_bill = JxcStockReduceBill.new
    #报损单编号
    @jxc_stock_reduce_bill.bill_no = @jxc_stock_reduce_bill.generate_bill_no
    #报损仓库
    @jxc_stock_reduce_bill.jxc_storage = self.jxc_storage
    #经手人
    @jxc_stock_reduce_bill.handler << self.handler
    #制单人
    @jxc_stock_reduce_bill.bill_maker << current_user
    #报损时间
    @jxc_stock_reduce_bill.reduce_date = self.check_date
    #备注
    @jxc_stock_reduce_bill.remark = '盘点生成，盘点单号:'+self.bill_no
    #生成报损单的盘点单
    @jxc_stock_reduce_bill.jxc_stock_count_bill = self

    reduceDetailArray.each do |reduceDetail|
      tempBillDetail = JxcBillDetail.new

      tempBillDetail.price = reduceDetail.price
      tempBillDetail.count = reduceDetail[:pl_count].to_d.abs  #报损数量(取绝对值)
      tempBillDetail.amount = reduceDetail[:pl_amount].to_d.abs  #报损金额(取绝对值)

      tempBillDetail.resource_product_id = reduceDetail.resource_product_id
      tempBillDetail.unit = reduceDetail.unit

      tempBillDetail.jxc_storage = reduceDetail.jxc_storage
      tempBillDetail.stock_reduce_bill_id = @jxc_stock_reduce_bill.id

      tempBillDetail.save
    end

    @jxc_stock_reduce_bill.save
  end

end
