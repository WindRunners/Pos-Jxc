class ExpiredWarningProduct
  #过期预警商品列表
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  include Mongoid::Multitenancy::Document

  tenant(:client)

  # field :resource_product_id, type:String #过期预警商品 ID
  # field :current_inventory, type:Integer #当前库存存量
  field :deadline, type: Time   #保质 截止日期
  field :expiration_date, type: Integer   #保质期剩余天数

  belongs_to :jxc_storage, foreign_key: :storage_id #预警仓库
  belongs_to :traceability, foreign_key: :traceability_id #溯源码关联

  scope :by_storage, -> (storage_id){
    where(:storage_id => storage_id) if storage_id.present?
  }


  #任务调度 扫描所有溯源信息 判断商品是否进入保质期预警
  def self.judge_expiration_warning
    @traceList = Traceability.where(:codetype => 0,:sellFlag => 0)

    @traceList.each do |traceObject|
      @store = traceObject.jxc_storage
      left_expired_days = traceObject.calc_left_expired_days

      #判断 商品的剩余保质期是否已经达到仓库预警限度，若是，则添加到保质期预警列表
      if left_expired_days <= @store.expiration_date_warning
        add_expired_warning_product(traceObject.id)
      end
    end

  end



  #添加 保质期预警商品
  def add_expired_warning_product(trace_id)

    begin
      @expiredWarningProduct = ExpiredWarningProduct.find_by(traceability_id: trace_id)
    rescue
      @expiredWarningProduct = nil
    end

    if !@expiredWarningProduct.present?

      begin
        @trace = Traceability.find(trace_id)
      rescue
        @trace = nil
      end

      if @trace.present?
        @expiredWarningProduct = ExpiredWarningProduct.new
        @expiredWarningProduct.deadline = @trace.deadline
        @expiredWarningProduct.expiration_date = (@trace.deadline.to_date - Time.now.to_date).to_i   #计算保质期剩余天数
        @expiredWarningProduct.jxc_storage = @trace.jxc_storage
        @expiredWarningProduct.traceability = @trace
      end

    end

  end

  #移除 保质期预警商品
  def self.remove_expired_warning_product()

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
