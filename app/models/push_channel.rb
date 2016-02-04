class PushChannel
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :delivery_user
  has_many :push_logs

  field :channel_id #移动设备推送ID
  field :success_count, type: Integer, default: 0 #成功次数
  field :fail_count, type: Integer, default: 0 #失败次数
end