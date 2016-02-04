=begin
酒库赠送礼包
=end
class GiftBag
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic

  field :receiver_mobile, type: String #接受者手机号
  field :sign_status, type: Integer #签收状态 -1:过期,0:待签收,1:已签收
  field :expiry_days, type: Integer #过期天数
  field :expiry_time, type: DateTime #失效时间
  field :sign_time, type: DateTime #签收时间
  field :content, type: String #礼包内容(eg:捎句话)
  field :memo, type: String #备注
  field :product_list, type: Hash #礼包商品{product_id_userinfo_id:{count:数量}}
  field :customer_id, type: String #送礼人小Cid
  field :receiver_customer_id, type: String #收礼人小Cid 认领时进行赋值,可作为历史查询(解决用户更换手机号后,历史查询问题)
  field :fail_product_list, type: Array #领取失败的商品列表

  belongs_to :import_bag #可能隶属于一个导入礼包
  belongs_to :import_bag_receiver #可能隶属于一个导入礼包接受用户

end