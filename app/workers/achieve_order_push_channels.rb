class AchieveOrderPushChannels
  @queue = :achieves_order_push_channels

  def self.perform(*args)

    channels, badge, log_id = args.first, args[1], args.last

    ios_client = Baidu::CloudPush.new('9qKGVvWRL4dPvLX7h4UFlI2n', 'AI9fNO8dVHjZFM7FHsXjlRwKX5TZzmbW')
    android_client = Baidu::CloudPush.new('YSG5VESAS4QsuKhUoiAFdPuH', 'uK7R7g9fX1pvomK1cBMFEmsYjbrGEtT3')


    ios_msg = {}

    ios_msg[:aps] = {
        :alert => "您有新的订单,请注意查收",
        :sound => "neworder.mp3",
        :badge => badge
    }

    android_msg = {
      title: "小达快跑",
      description: "您有新的订单,请注意查收",
      notification_builder_id: 0,
      notification_basic_style: "2",
      open_type:3
    }

    push_log = PushLog.find(log_id)

    fail_channels = []

    channels.each do |channel|
      arr = channel.split('|')

      r = {}

      if arr.first == 'IOS'
        r = ios_client.push_single_device(arr.last, ios_msg, {msg_type: 1, deploy_status: 2})
      elsif arr.first == 'ANDROID'
        r = android_client.push_single_device(arr.last, android_msg, {msg_type: 1})
      else
        next
      end

      unless r.result
        fail_channels << channel
      end

      json = r.to_json

      json[:pushed_at] = Time.now

      push_log.logs << json

      Rails.logger.info json
    end
    push_log.save!


    if fail_channels.present?
      Resque.enqueue_at(10.seconds.from_now, AchieveOrderPushChannels, fail_channels, badge, log_id)
    end
  end
end