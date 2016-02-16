class JxcEnteringStock
  # 期初库存录入单
  include Mongoid::Document
  include Mongoid::Timestamps
  # include JxcSettings
  # include AutoSort
  include AASM
  include Mongoid::Multitenancy::Document

  tenant(:client)

  after_initialize do
    # Rails.logger.info "auto_sort====#{base.inspect}"
    self.sort = BuilderSort.current(self.model_name) if sort.blank?
  end
  after_create do
    BuilderSort.build(self.model_name)
  end

  # after_initialize :set_enteringstock_no #生成期初入库单号
  field :enteringstock_no, type: String
  # ,default: "#{t=Time.now.strftime("%Y%m%d-%H%M%S");r=rand(999999);"QCRKD-"+t+"-"+r.to_s}"
  field :remark, type: String #备注
  field :aasm_state, type: String #审核状态 审核 作废 红冲
  field :sort, type: Integer #排序码
  has_many :jxc_bill_details #单据明细
  belongs_to :jxc_storage #仓库信息
  belongs_to :handler, :class_name => "User", foreign_key: :handler_id #经手人
  belongs_to :creator, :class_name => "User" #制单人
  belongs_to :verifier, :class_name => "User" #审核人
  field :audit_date,type: String #审核日期


  aasm do
    state :waiting, :initial => true #等待
    state :audit #审核
    state :dashed #红冲
    state :nullify #作废


    event :to_audit do
      before do
        inventory #审核通过 转化库存
      end
      after do
        self.verifier= JxcSetting.current_user
        self.audit_date= Time.now.strftime("%Y-%m-%d %H:%M:%S")
        save!
      end
      transitions :from => :waiting, :to => :audit
    end
    event :to_nullify do
      after do
        self.verifier= JxcSetting.current_user
        self.audit_date= Time.now.strftime("%Y-%m-%d %H:%M:%S")
        save!
      end
      transitions :from => :waiting, :to => :nullify
    end
    event :to_dashed do
      before do
        change_stock #红冲 修改库存
      end
      after do
        self.verifier= JxcSetting.current_user
        self.audit_date=Time.now.strftime("%Y-%m-%d %H:%M:%S")
        save!
      end
      transitions :from => :audit, :to => :dashed
    end


  end

  def inventory
    #
    # field :unit, type: String    #基本单位
    # field :cost_price, type: BigDecimal, default: 0.00  #成本价
    # field :count, type: Integer, default: 0    #商品数量
    # field :amount, type: BigDecimal, default: 0.00 #库存金额
    # field :virtual_count, type: Integer   #虚拟数量
    #
    # belongs_to :jxc_storage   #详情信息 所属的仓库
    # belongs_to :product  #每条详情信息 包含一个商品
    @productDetails= JxcBillDetail.where(:entering_stock_id => self.id)
    p "@productDetails=self.jxc_bill_details#{@productDetails.to_json}"
    for p in @productDetails
      begin
        @storageProduct=JxcStorageProductDetail.find_by(:jxc_storage => self.jxc_storage, :resource_product_id => p.resource_product_id)
      rescue
        @storageProduct=nil
      end
      if @storageProduct.present?
        previous_count=@storageProduct.count
        @storageProduct.unit=p.unit
        @storageProduct.cost_price=p.price
        @storageProduct.count +=p.count
        after_count= @storageProduct.count
        @storageProduct.amount +=p.amount
        if @storageProduct.update
          log(p, self, previous_count, after_count, '0', '1')
        end
      else
        @storageProduct=JxcStorageProductDetail.new(:unit => p.unit, :cost_price => p.price, :count => p.count, :amount => p.amount, :jxc_storage => self.jxc_storage, :resource_product_id => p.resource_product_id)
        p "@storageProduct========#{@storageProduct.to_json}"
        if @storageProduct.save!
          log(p, self, 0, p.count, '0', '1')
        end
      end


    end
  end

  def change_stock
    @productDetails=JxcBillDetail.where(:entering_stock_id => self.id)
    for p in @productDetails
      @storageProduct=JxcStorageProductDetail.find_by(:jxc_storage => self.jxc_storage, :resource_product_id => p.resource_product_id)
      p "@storageProduct========#{@storageProduct.to_json}"
      previous_count=@storageProduct.count
      @storageProduct.count = @storageProduct.count - p.count
      @storageProduct.amount = @storageProduct.amount - p.amount
      after_count= @storageProduct.count
      if @storageProduct.save!
        log(p, self, previous_count, after_count, '4', '2')
      end
    end
  end

  def log(product, entering, previous_count, after_count, op_type, bill_status)
    storageJournal = JxcStorageJournal.new

    storageJournal.resource_product_id = product.resource_product_id #商品
    storageJournal.jxc_storage = entering.jxc_storage #仓库
    storageJournal.user = entering.handler #经手人

    storageJournal.previous_count = previous_count #库存变更前存量
    storageJournal.after_count = after_count #库存变更后存量
    storageJournal.count = product.count #单据明细数量
    storageJournal.price = product.price #成本价
    storageJournal.amount = product.amount
    storageJournal.op_type = op_type #操作类型 <入库>
    storageJournal.jxc_entering_stock = entering #库存变更依据的 单据
    storageJournal.bill_no = entering.enteringstock_no #单据编号
    storageJournal.bill_type = 'entering_stock'
    storageJournal.bill_status = bill_status
    storageJournal.bill_create_date = self.created_at.strftime('%Y/%m/%d')

    storageJournal.save
  end

  def change_state(state)
    if state =="audit"
      to_audit if may_to_audit? && waiting?
    elsif state =="nullify"
      to_nullify if may_to_nullify? && waiting?
    elsif state =="dashed"
      to_dashed if may_to_dashed? && audit?
    end
  end


  def count(j)
    a=0
    j.collect { |jj| a+=jj.count }
    a
  end

  def amount(j)
    a=0
    j.collect { |jj| a+=jj.amount }
    a
  end

  # def sort
  #   @entering_stock= JxcEnteringStock.order(:created_at => "ASC").last
  #   p "-=-=-=-=-=-=-=-=-#{@entering_stock.to_json}"
  #   if @entering_stock.present?
  #     p "@entering_stock.sort + 1#{@entering_stock.sort + 1}"
  #     self.sort = @entering_stock.sort.to_i + 1
  #   else
  #     self.sort = 1
  #   end
  # end
end
