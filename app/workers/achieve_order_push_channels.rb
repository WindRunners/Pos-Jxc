class AchieveOrderPushChannels
  @queue = :achieves_order_push_channels

  def self.perform(*args)

    channels, badge, log_id = args.first, args[1], args.last

    ios_client = Baidu::CloudPush.new('jZ73ExSqodxLIsT9WgwVUb2E', 'xG4q4XzqEeSbLG2A2GWQrIWO4hEaGS44')
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
        open_type: 3
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

      if r.result == false and ![30602, 30608].include? r.error_code
        fail_channels << channel
      end

      begin
        pushChannel = PushChannel.find_by(channel_id: channel)

        if r.result
          pushChannel.inc(success_count: 1)
        elsif [30602, 30608].include? r.error_code
          pushChannel.destroy
        else
          pushChannel.inc(fail_count: 1)
        end
      rescue
      end


      json = r.to_json

      json[:channel] = channel
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