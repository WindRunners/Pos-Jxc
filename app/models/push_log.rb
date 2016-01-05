class PushLog
  include Mongoid::Document
  include Mongoid::Timestamps

  field :order_id
  field :userinfo_id
  field :logs, type: Array, default: []
end