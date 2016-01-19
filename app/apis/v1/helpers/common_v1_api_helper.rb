module CommonV1APIHelper


  def CommonV1APIHelper.share_integral_syn(customer_id)
    data = {}
    share_integral_record = ShareIntegralRecord.where(:register_customer_id => customer_id, :is_confirm => 0).first

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
    data
  end

  def CommonV1APIHelper.product_ticket_syn(customer_id)
    data = {}
    share_integral_record = ShareIntegralRecord.where(:register_customer_id => customer_id, :is_confirm => 0).first

    if share_integral_record.present?

      share_customer = Customer.find(share_integral_record.shared_customer_id)
      register_customer = Customer.find(share_integral_record.register_customer_id)
      #分享者奖励商品入酒库
      share_customer.integral+= share_integral_record.share_integral.shared_give_integral
      share_customer.save
      #分享者酒券卡包生成
      register_customer.integral+= share_integral_record.share_integral.register_give_integral
      register_customer.save
      #更新记录表状态
      share_integral_record.is_confirm = 1
      share_integral_record.save



      data['message']="推荐奖励增加成功！"
      data['flag']=1

    else
      data['message']="无有效推荐有奖记录！"
      data['flag']=0
    end
    data
  end


end