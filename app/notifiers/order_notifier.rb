class OrderNotifier
  def order_paid(order_id)
    order = Order.find(order_id)
    # client = BaiduCloudPush::Client.new()
    # message = { title: 'title', description: 'desc' }
    # client.push_all msg: message
    # p message

    #client = Baidu::CloudPush('','')
  end
end