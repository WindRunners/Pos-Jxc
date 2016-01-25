class JxcCostAdjustBill
  ## 进销存 成本调整单
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic

  field :bill_no, type: String            #单据编号
  field :customize_bill_no, type: String  #自定义单据编号
  field :adjust_date, type: DateTime      #调整日期
  field :remark, type: String             #备注

  field :bill_status, type: String, default: '0'  #单据状态 ( -1:已作废 | 0:已创建 | 1:已审核 | 2:已红冲 )

  belongs_to :jxc_storage, foreign_key: :storage_id #调整仓库
  has_and_belongs_to_many :handler, class_name:'User', foreign_key: :handler_id  #经手人
  has_and_belongs_to_many :bill_maker, class_name:'User', foreign_key: :maker_id  #制单人

  has_many :jxc_bill_details  #单据明细
  has_many :jxc_storage_journals #库存变更日志
  #生成单据编号
  def generate_bill_no
    random = ''
    6.times.each{
      random += rand(9).to_s
    }
    'CBTZD'+'-'+Time.now.strftime('%Y%m%d')+'-'+Time.now.strftime('%H%M%S')+'-'+random
  end


  #审核
  def audit(current_user)
    #结果集
    result = {}
    result[:flag] = 0

    #如果单据状态为： 已创建
    if self.bill_status == '0'

      #单据商品详情
      billDetailsArray = JxcBillDetail.includes(:product).where(cost_adjust_bill_id: self.id)
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

          if store_product_detail.present?
            store_product_detail.cost_price = billDetail[:adjusted_price]
            store_product_detail.amount = (store_product_detail.cost_price.to_d * store_product_detail.count.to_d).round(2)
            store_product_detail.update

            #记录库存变更日志
            storageChangeLog = JxcStorageJournal.new

            storageChangeLog.jxc_storage = store                          #调整仓库
            storageChangeLog.product = billDetail.product                 #调整商品
            storageChangeLog.staff = self.handler                         #经手人

            storageChangeLog.previous_count = store_product_detail.count
            storageChangeLog.after_count = store_product_detail.count
            storageChangeLog.count = billDetail[:inventory_count]                     #调整数量
            storageChangeLog[:price] = billDetail[:origin_price]   #原成本价
            storageChangeLog[:adjusted_price] = billDetail[:adjusted_price]   #调后成本价
            storageChangeLog[:amount] = billDetail[:amount]               #调整金额
            storageChangeLog.op_type = '5'                                #操作类型 <成本调整>
            storageChangeLog.jxc_cost_adjust_bill = self                  #库存变更依据的 单据
            storageChangeLog.bill_no = self.bill_no                       #单据编号
            storageChangeLog.bill_type = 'cost_adjust'
            storageChangeLog.bill_status = '1'
            storageChangeLog.bill_create_date = self.created_at.strftime('%Y/%m/%d')

            storageChangeLog.save
          end

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
    #结果集
    result = {}
    result[:flag] = 0

    if self.bill_status == '1'

      #单据商品详情
      billDetailsArray = JxcBillDetail.includes(:product).where(cost_adjust_bill_id: self.id)
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

          if store_product_detail.present?
            store_product_detail.cost_price = billDetail[:origin_price]  #调回原成本价
            store_product_detail.amount = (store_product_detail.cost_price.to_d * store_product_detail.count.to_d).round(2)
            store_product_detail.update

            #记录库存变更日志
            storageChangeLog = JxcStorageJournal.new

            storageChangeLog.product = billDetail.product                 #调整商品
            storageChangeLog.jxc_storage = store                          #调整仓库
            storageChangeLog.staff = self.handler                         #经手人

            storageChangeLog.previous_count = store_product_detail.count
            storageChangeLog.after_count = store_product_detail.count
            storageChangeLog.count = billDetail[:inventory_count]                     #调整数量
            storageChangeLog[:price] = billDetail[:adjusted_price] #原成本价
            storageChangeLog[:adjusted_price] = billDetail[:origin_price]   #调后成本价
            storageChangeLog[:amount] = '-'+billDetail[:amount]              #调整金额
            storageChangeLog.op_type = '4'                                #操作类型 <红冲>
            storageChangeLog.jxc_cost_adjust_bill = self                  #库存变更依据的 单据
            storageChangeLog.bill_no = self.bill_no                       #单据编号
            storageChangeLog.bill_type = 'cost_adjust'
            storageChangeLog.bill_status = '2'
            storageChangeLog.bill_create_date = self.created_at.strftime('%Y/%m/%d')

            storageChangeLog.save
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
    #操作结果集
    result = {}
    result[:flag] = 0

    if self.bill_status == '0'
      #更新单据状态
      self.bill_status = '-1'
      self.update

      #返回审核结果
      result[:flag] = 1
      result[:msg] = '单据已成功作废。'
    else
      result[:msg] = '单据当前状态无法作废!'
    end

    return result
  end
end
