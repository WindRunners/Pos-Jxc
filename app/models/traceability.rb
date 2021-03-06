class Traceability
  #追溯
  include Mongoid::Document
  include Mongoid::Timestamps

  field :barcode, type: String #条形码
  field :codetype,type: Integer #0母码 1子码
  field :subCodeCount, type: Integer #子码个数
  field :seqcode,type: String #顺序码 5-1 5-2 5-3 5-4 5-5
  field :printdate,type: Time #打印时间
  field :flag,type: Integer, default: 0 #是否打印 0未打印 1已打印
  field :generateSubCodeFlag, type: Integer, default:0  #是否已经生成过子码（ 0：未生成  1：已生成 ）
  field :sellFlag, type: Integer, default:0   #销售标志 （ 0：未销售   1：已销售 ）

  field :resource_product_id, type: String #溯源商品信息 (商品为：ActiveResource Object)

  field :production_date, type: Time #商品生产日期
  field :expiration_date, type: Integer  #商品保质期（ 天数 ）
  field :deadline, type: Time #商品过保日期

  belongs_to :parent, :class_name => "Traceability", :foreign_key => :parent_id #上级科目
  has_many :childs, :class_name => "Traceability", :autosave => true, :dependent => :destroy #下级科目

  belongs_to :jxc_storage  #仓库
  # belongs_to :product   #商品

  belongs_to :jxc_bill_detail #对应采购入库单据明细
  belongs_to :jxc_transfer_bill_detail #对应要货单据明细


  def generate_root_barcode
    barcode = '9'
    barcode += Time.now.strftime("%y%m%d%H%M%S")
    4.times.each{
      barcode += rand(9).to_s
    }
    return barcode
  end

  def product
    begin
      @product = Warehouse::Product.find(self.resource_product_id)
    rescue
      @product = nil
    end
  end

  #计算剩余保质天数
  def calc_left_expired_days
    left_expired_days = (self.deadline.to_date - Time.now.to_date).to_i
  end

end