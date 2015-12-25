class Store
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  include Mongoid::Paperclip
  include Mongoid::Geospatial

  field :name, type: String #门店名称
  field :manager, type: String #负责人
  field :describe, type: String #描述
  field :type, type: Integer #门店类型，虚拟店铺：0，实体店铺：1
  field :longitude, type: Float #经度
  field :latitude, type: Float #纬度
  field :position, type: String #位置描述
  field :idf_url, type: String # 身份真正面
  field :idb_url, type: String # 身份证反面
  field :bp_url, type: String # 身份证反面
  field :location, type: Point, spatial: true, default: []

  has_mongoid_attached_file :idpf,
                            :default_url => '/missing.png',
                            :path => "public/upload/image/:class/:id/:filename",
                            :url => "/upload/image/:class/:id/:basename.:extension"
  validates_attachment_content_type :idpf, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

  has_mongoid_attached_file :idpb,
                            :default_url => '/missing.png',
                            :path => "public/upload/image/:class/:id/:filename",
                            :url => "/upload/image/:class/:id/:basename.:extension"
  validates_attachment_content_type :idpb, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

  has_mongoid_attached_file :bp,
                            :default_url => '/missing.png',
                            :path => "public/upload/image/:class/:id/:filename",
                            :url => "/upload/image/:class/:id/:basename.:extension"
  validates_attachment_content_type :bp, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

  index({location: "2d"}, {min: -200, max: 200})

  belongs_to :userinfo #门店隶属于联盟商userinfo
  has_and_belongs_to_many :delivery_users,
                          :autosave => true #门店下面有多个配送员负责配送

  validates :name, :manager, :type, :longitude, :latitude, :position, presence: true

  before_save :add_jpg_url


  def add_jpg_url
    self.idf_url = idpf.url
    self.idb_url = idpb.url
    self.bp_url = bp.url

    #设置定位信息
    self.location = [self.longitude,self.latitude]
  end


  #订单支付成功,设置订单最近门店
  def set_order_store(order_id)
    order = Order.find(order_id)

    storeId = 0
    distance = 0
    if order.location.present? && order.location.to_a[0] != 0 && order.location.to_a[1] != 0 #定位有效
      #查询离小C最近的门店
      storeResult = Store.where({'userinfo_id'=>order['userinfo_id'],'type'=>1}).limit(1).geo_near(order.location.to_a)

      if storeResult.present? && storeResult['results']!=0
         storeId = storeResult['results'][0]['obj']['_id']
         distance = storeResult['results'][0]['dis']
      end
    end

    #门店定位失败或找不到时,查询虚拟门店
    if storeId == 0
      store = Store.where({'userinfo_id'=>order['userinfo_id'],'type'=>0}).first
      storeId = store.id if store.present?
    end

    #更新订单门店及配送距离
    Order.where(id: order_id).update({'store_id'=> storeId,'distance'=>distance})
  end

end