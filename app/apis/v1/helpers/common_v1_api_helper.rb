module CommonV1APIHelper


  def CommonV1APIHelper.share_integral_syn(customer_id)
    data = {}
    begin
      share_integral_record = ShareIntegralRecord.where(:register_customer_id => customer_id, :is_confirm => 0, :share_integral_id => {"$exists" => "true"}).first
      if share_integral_record.present?
        share_customer = Customer.find(share_integral_record.shared_customer_id)
        register_customer = Customer.find(share_integral_record.register_customer_id)
        share_customer.integral+= share_integral_record.share_integral.shared_give_integral
        share_customer.save
        register_customer.integral+= share_integral_record.share_integral.register_give_integral
        register_customer.save
        share_integral_record.is_confirm = 1
        share_integral_record.save
        data['message']="推荐奖励增加成功！"
        data['flag']=1
      else
        data['message']="无有效推荐有奖记录！"
        data['flag']=0
      end
    rescue
      data['message']="异常！"
      data['flag']=-1
    end
    data
  end

  def CommonV1APIHelper.product_ticket_syn(customer_id)
    data = {}
    begin
      share_integral_record = ShareIntegralRecord.where(:register_customer_id => customer_id, :is_confirm => 0, :product_ticket_id => {"$exists" => "true"}).first
      if share_integral_record.present?

        share_customer = Customer.find(share_integral_record.shared_customer_id)
        register_customer = Customer.find(share_integral_record.register_customer_id)
        #分享者奖励商品入酒库，卡包内酒券失效
        card_bag = CardBag.where(:customer_id => share_customer.id, :product_ticket_id => share_integral_record.product_ticket_id, :status => 0).first
        if card_bag.present?

          SpiritRoom.new.save_product_ticket_product(card_bag.product_ticket.id, share_customer.id)
          card_bag.status = 1
          card_bag.save
          #注册者酒券卡包生成
          register_card_bag =card_bag.product_ticket.card_bags.build()
          register_card_bag.customer_id = register_customer.id
          register_card_bag.source = 1
          register_card_bag.start_date = card_bag.start_date
          register_card_bag.end_date = card_bag.end_date
          register_card_bag.save

          #更新记录表状态
          share_integral_record.is_confirm = 1
          share_integral_record.save


          data['message']="酒券回调成功！"
          data['flag']=1

        else
          data['message']="无有效卡包记录！"
          data['flag']=0
        end
      else
        data['message']="无有效分享记录！"
        data['flag']=0

      end
    rescue Exception => e
      Rails.logger e.message
      data['message']="异常！"
      data['flag']=-1
    end
    data
  end


end