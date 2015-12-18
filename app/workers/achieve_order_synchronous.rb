class AchieveOrderSynchronous

  @queue = :achieves_queue_order_synchronous

  def self.perform(orderjson)

      baseurl = ENV["WAREHOUSE_URL"] || "http://localhost:3001/"
      url = baseurl + "api/v1/order/order_synchronous"
      headers = {}
      headers['X-Warehouse-Rest-Api-Key'] = '5604a417c3666e0b7300001a'

      options = {}
      options['order'] = orderjson

      options['multipart'] = true

      response = RestClient.post url, options, headers

  end

end