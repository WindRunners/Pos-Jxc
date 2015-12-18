class UserinfoOppenid
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :userinfo

  field :openid,type: String,default: "" #转账唯一标示
  field :name,type: String,default: "" #微信实名制姓名
end