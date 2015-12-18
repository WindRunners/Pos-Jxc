class VerifyCode
  include Mongoid::Document
  include Mongoid::Timestamps

  field :key,  type: String #验证码标识
  field :code, type: String  #验证码

  index({ key: 1 }, { unique: true, name: "key_index" }) #标识唯一索引

end