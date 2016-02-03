class Store
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  include Mongoid::Paperclip
  include Mongoid::Geospatial
  include Math

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

  validates :name, :type, :longitude, :latitude, :position, presence: true

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
    store_name = ''
    if order.location.present? && order.location.to_a[0] != 0 && order.location.to_a[1] != 0 #

      location = [order.location.to_a[1],order.location.to_a[0]] #调整经纬度
      # #查询离小C最近的门店
      # storeResult = Store.where({'userinfo_id'=>order['userinfo_id'],'type'=>1}).geo_near(location)
      # if storeResult.present? && storeResult['results']!=0
      #    storeId = storeResult['results'][0]['obj']['_id']
      #    distance = storeResult['results'][0]['dis']
      # end

      near_store = Store.where({'userinfo_id'=>order['userinfo_id'],'type'=>1}).near('location'=> location).first
      if near_store.present?
        storeId = near_store.id
        distance = get_distance_for_points(near_store.location.to_a[0], near_store.location.to_a[1], order.location.to_a[1], order.location.to_a[0])
        store_name = near_store.name
      end
    end

    #门店定位失败或找不到时,查询虚拟门店
    if storeId == 0
      near_store = Store.where({'userinfo_id'=>order['userinfo_id'],'type'=>0}).first
      storeId = near_store.id if near_store.present?
      store_name = near_store.name
    end

    channels = []
    dusers = DeliveryUser.where(:store_ids => storeId, :work_status => 1)

    dusers.each do |user|
      channels.concat user.channel_ids if user.channel_ids.present?
    end

    logger.info channels

    push_log = PushLog.create(order_id:order_id, userinfo_id:order['userinfo_id'])

    Resque.enqueue(AchieveOrderPushChannels, channels, 0, push_log.id)


    #更新订单门店及配送距离
    Order.where(id: order_id).update({'store_id'=> storeId,'distance'=>distance,'store_name'=>store_name})
    OrderStateChange.find(order_id).update(:store_id => storeId) #更新订单总表门店信息


    #推送web端
    data = {
        orderno: order.orderno,order_id: order.id
    }
    web_users = User.where({'store_ids'=>storeId})
    web_users.each do |web_user|
      MessageBus.publish "/channel/#{web_user.id.to_s}", data
    end

  end


  #获取两坐标点的距离
  def get_distance_for_points(lng1, lat1, lng2, lat2)

    lat_diff = (lat1 - lat2)*PI/180.0
    lng_diff = (lng1 - lng2)*PI/180.0
    lat_sin = Math.sin(lat_diff/2.0) ** 2
    lng_sin = Math.sin(lng_diff/2.0) ** 2
    first = Math.sqrt(lat_sin + Math.cos(lat1*PI/180.0) * Math.cos(lat2*PI/180.0) * lng_sin)
    Math.asin(first) * 2 * 6378137.0
  end

end