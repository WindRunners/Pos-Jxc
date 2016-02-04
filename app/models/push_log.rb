class PushLog
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :push_channel

  field :order_id
  field :userinfo_id
  field :logs, type: Array, default: []
end