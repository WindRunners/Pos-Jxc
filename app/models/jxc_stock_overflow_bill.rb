class JxcStockOverflowBill
  ## 进销存 报溢单
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic

  field :bill_no, type: String            #单据编号
  field :customize_bill_no, type: String  #自定义单据编号
  field :overflow_date, type: DateTime    #报溢日期
  field :remark, type: String             #备注

  field :bill_status, type: String, default: '0'    #单据状态 ( -1:已作废 | 0:已创建 | 1:已审核 | 2:已红冲 )

  belongs_to :jxc_storage, foreign_key: :storage_id #报溢仓库
  has_and_belongs_to_many :handler, class_name:'User', foreign_key: :handler_id #经手人
  has_and_belongs_to_many :bill_maker, class_name:'User', foreign_key: :maker_id #制单人

  belongs_to :jxc_stock_count_bill  #盘点单

  has_many :jxc_bill_details    #单据商品明细

  #生成单据编号
  def generate_bill_no
    random = ''
    6.times.each{
      random += rand(9).to_s
    }
    'BYD'+'-'+Time.now.strftime('%Y%m%d')+'-'+Time.now.strftime('%H%M%S')+'-'+random
  end

  #审核
  def audit(current_user)
    #审核结果集
    result = {}
    result[:flag] = 0

    if self.bill_status == '0'
      #单据商品详情
      billDetailsArray = JxcBillDetail.includes(:product).where(stock_overflow_bill_id: self.id)
      #仓库
      store = self.jxc_storage

      if billDetailsArray.present?
        billDetailsArray.each do |billDetail|
          #仓库&商品 明细
          begin
            store_product_detail = JxcStorageProductDetail.find_by(:jxc_storage => store,:product => billDetail.product)
          rescue
            store_product_detail = nil
          end

          #如果 仓库中存在商品 ，更新存量
          if store_product_detail.present?
            previous_count = store_product_detail.count #更新前库存
            after_count = previous_count + billDetail.count #更新后库存

            #报溢后 库存数量
            store_product_detail.count = after_count
            #报溢后 库存金额
            store_product_detail.amount = store_product_detail.calcInventoryAmount(store_product_detail.cost_price,after_count);

            store_product_detail.update
          else
            #如果不存在，则添加
            store_product_detail = JxcStorageProductDetail.new

            store_product_detail.product = billDetail.product
            store_product_detail.jxc_storage = billDetail.jxc_storage
            store_product_detail.unit = billDetail.unit
            store_product_detail.count = billDetail.count
            store_product_detail.cost_price = billDetail.price
            store_product_detail.amount = billDetail.amount

            store_product_detail.save

            #更新后库存
            after_count = previous_count+billDetail.count
          end

          #仓库商品明细变更后，记录变更日志
          storageJournal = JxcStorageJournal.new

          storageJournal.product = billDetail.product   #商品
          storageJournal.jxc_storage = store    #仓库
          storageJournal.staff = self.handler  #经手人

          storageJournal.previous_count = previous_count   #库存变更前存量
          storageJournal.after_count = after_count   #库存变更后存量
          storageJournal.count = billDetail.count #单据明细数量
          storageJournal.price = store_product_detail.cost_price #报溢时，库存单价
          storageJournal.amount = billDetail.amount
          storageJournal.op_type = '3'  #操作类型 <报溢>
          storageJournal.jxc_stock_overflow_bill = self  #库存变更依据的 单据
          storageJournal.bill_no = self.bill_no #单据编号
          storageJournal.bill_type = 'stock_overflow'
          storageJournal.bill_status = '1'
          storageJournal.bill_create_date = self.created_at.strftime('%Y/%m/%d')

          storageJournal.save

        end
      end

      #更细单据状态
      self.bill_status = '1'
      self.update

      #返回审核结果
      result[:flag] = 1
      result[:msg] = '审核通过'
    else
      result[:msg] = '单据当前状态无法审核!'
    end

    return result
  end


  #冲账
  def strike_a_balance(current_user)
    #审核结果集
    result = {}
    result[:flag] = 0

    if self.bill_status == '1'

      #单据商品详情
      billDetailsArray = JxcBillDetail.includes(:product).where(stock_overflow_bill_id: self.id)
      #仓库
      store = self.jxc_storage

      if billDetailsArray.present?
        billDetailsArray.each do |billDetail|

          #仓库&商品 明细
          begin
            store_product_detail = JxcStorageProductDetail.find_by(:jxc_storage => store,:product => billDetail.product)
          rescue
            store_product_detail = nil
          end

          #如果 仓库中存在商品 ，更新存量
          if store_product_detail.present?
            previous_count = store_product_detail.count #更新前库存
            after_count = previous_count - billDetail.count #更新后库存

            store_product_detail.count = after_count
            store_product_detail.amount = store_product_detail.calcInventoryAmount(store_product_detail.cost_price,after_count)

            store_product_detail.update

            #仓库商品明细变更后，记录变更日志
            storageJournal = JxcStorageJournal.new

            storageJournal.product = billDetail.product   #商品
            storageJournal.jxc_storage = store    #仓库
            storageJournal.staff = self.handler   #经手人

            storageJournal.previous_count = previous_count   #库存变更前存量
            storageJournal.after_count = after_count   #库存变更后存量
            storageJournal.count = -billDetail.count #单据明细数量
            storageJournal.price = store_product_detail.price
            storageJournal.amount = -billDetail.amount
            storageJournal.op_type = '4'  #操作类型 <红冲>
            storageJournal.jxc_stock_overflow_bill = self  #库存变更依据的 单据
            storageJournal.bill_no = self.bill_no #库存变更依据的 单据编号
            storageJournal.bill_type = 'stock_overflow'
            storageJournal.bill_status = '2'
            storageJournal.bill_create_date = self.created_at.strftime('%Y/%m/%d')

            storageJournal.save
          end
        end
      end


      #更新单据状态
      self.bill_status = '2'  #<红冲>
      self.update

      #审核结果返回
      result[:flag] = 1
      result[:msg] = '单据已红冲'
    else
      result[:msg] = '单据当前状态无法红冲!'
    end

    return result
  end


  #作废
  def bill_invalid
    #处理结果
    result = {}

    if self.bill_status == '0'
      self.bill_status = '-1'
      self.update
      result[:flag] = 1
      result[:msg] = '单据已作废'
    else
      result[:flag] = 0
      result[:msg] = '单据当前状态无法作废!'
    end

    return result
  end

end
