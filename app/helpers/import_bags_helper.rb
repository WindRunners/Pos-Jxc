module ImportBagsHelper

  #发送导入礼包
  def ImportBagsHelper.sendImportBags(importBag)

    #获取受理人列表
    importBagsReceivers = importBag.import_bag_receivers

    product_list_hash = {}
    importBag.product_list.each do |k,v|

      product_list_hash["#{k}_#{importBag['userinfo_id'].to_s}"] = v
    end

    gif_bags = []
    importBagsReceivers.each do |importBagsReceiver|

      gif_bag = GiftBag.new()
      gif_bag.receiver_mobile = importBagsReceiver.receiver_mobile
      gif_bag.expiry_days = importBag.expiry_days
      gif_bag.expiry_time = Time.now+86400*importBag.expiry_days
      gif_bag.sign_status = 0
      gif_bag.content = importBagsReceiver.memo.present? ? importBagsReceiver.memo : importBag.memo
      gif_bag.product_list = product_list_hash
      gif_bag.import_bag = importBag
      gif_bag.import_bag_receiver = importBagsReceiver
      customer = Customer.find_by_mobile(importBag.sender_mobile)
      gif_bag['customer_id'] = customer.id.to_s
      gif_bag['created_at'] = Time.now#批量插入时,需要进行手动设置时间
      gif_bag['updated_at'] = Time.now#批量插入时,需要进行手动设置时间
      gif_bags << gif_bag.as_document
    end
    #批量插入
    batchResult = GiftBag.collection.insert_many(gif_bags)
    batchResult.inserted_ids.each do |gift_bag_id|
      Resque.enqueue_at(importBag.expiry_days.days.from_now, AchieveGiftBagExpiry, gift_bag_id)
    end
  end
end
