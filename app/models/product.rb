class Product
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Taggable
  # include Mongoid::TaggableOn
  include Wisper::Publisher
  include Mongoid::Attributes::Dynamic

  disable_tags_index! # will disable index creation

  resourcify

  #validates :qrcode, presence: true

  belongs_to :state
  belongs_to :panic_buying
  belongs_to :mobile_category

  # taggable_on :activities

  field :full_reduction_id, type: String
  field :promotion_discount_id, type: String
  field :gift_full_reduction_ids, type: Array, default: []
  field :coupon_id, type: String
  field :title
  field :brand
  field :specification
  field :origin
  field :manufacturer

  field :qrcode
  field :qrcode_suffix

  field :avatar_url
  field :main_url
  field :desc_url

  field :mobile_category_name, default: '其他' #类别名称
  field :mobile_category_num, type: Integer, default: 0 #类别排序号

  field :purchasePrice, type: Float, default: 0 #进价
  field :price, type: Float, default: 0 #
  field :panic_price, type: Float, default: 0 #活动价格
  field :integral, type: Integer, default: 1 #积分
  field :stock, type: Integer, default: 0 #库存数量
  field :panic_quantity, type: Integer, default: 0 #活动数量
  field :sale_count, type: Integer, default: 0 #销量
  field :panic_sale_count, type: Integer, default: 0 #活动销量

  field :alarm_stock, type: Integer,default: 10 # 预警库存数量

  field :num, type: Integer, default: 0 #排序号

  field :exposure_num, type: Integer, default: 0 #商品的曝光数:商品被展示次数
  field :exposure_attrive_num, type: Integer, default: 0 #商品的曝光到达数:商品被展示后，用户点击访问的次数

  attr_accessor :pid,:userinfo_id

  #before_save :check_stock

  before_save :check_valid

  after_save :set_keywords

  ##进销存属性
  has_many :jxc_bill_details  #进销存单据商品详情
  has_many :jxc_transfer_bill_details #进销存 调拨单，要货单 商品信息
  has_many :jxc_storage_journal #仓库变更明细中的 商品信息
  has_many :jxc_storage_product_detail   #仓库商品明细中的 商品信息

  def pid
    id
  end

  def avatar
    self.avatar_url ||= 'missing.png'
    RestConfig::IMG_SERVER + self.avatar_url
  end

  def main
    if self.main_url.present?
      RestConfig::IMG_SERVER + self.main_url
    else
      'missing.png'
    end
  end

  def desc
    if self.desc_url.present?
      RestConfig::IMG_SERVER + self.desc_url
    else
      'missing.png'
    end

  end

  def coupon
    begin
      result << Coupon.find(coupon_id)
    rescue
    end
    result
  end

  def fullReduction
    begin
      FullReduction.find(full_reduction_id) if full_reduction_id.present?
    rescue
    end
  end

  def category_name
    mobile_category_name.present? ? mobile_category_name : '其他'
  end

  def self.shop_id(id)
    with(collection: "products#{id}")
  end

  def shop_id(id)
    @userinfo_id = id

    with(collection: "products#{id}")
  end

  def self.shop(user)
    @userinfo_id = user.userinfo.id

    with(collection: user.shop_id) if user.present?
  end

  def shop(user)
    @userinfo_id = user.userinfo.id

    with(collection: user.shop_id) if user.present?
  end

  private

  # def check_stock
  #   if self.stock <= 0 and self.state.name=='已上架' then
  #     self.state = State.find_by(name: "补货中")
  #   end
  # end

  def set_keywords

    if self.state.value == 'online' then
      Resque.enqueue(AchieveProductKeywords, @userinfo_id, self.title)
    end

    subscribe(StatisticTotal.new)
    broadcast(:after_product_save, id.to_s, @userinfo_id.to_s)
  end

  def check_valid
    if state.value == 'online'

      self.integral ||= 0

      if self.integral < 1
        errors.add(:base, '积分不能为0')
        return false
      end

      self.purchasePrice ||= 0

      if self.purchasePrice < 0.01
        errors.add(:base, '进价必须大于0')
        return false
      end

      self.price ||= 0
      if self.price < 0.01
        errors.add(:base, '零售价必须大于0')
        return false
      end
    end

    if self.mobile_category.blank?

      self.mobile_category_name = '其他' if self.mobile_category_name.blank?
      self.mobile_category = MobileCategory.find_or_create_by(title:self.mobile_category_name, userinfo_id:@userinfo_id)
    else
      self.mobile_category_name = self.mobile_category.title
      self.mobile_category_num = self.mobile_category.num
    end



  end

  def to_s
    self.title
  end

end
