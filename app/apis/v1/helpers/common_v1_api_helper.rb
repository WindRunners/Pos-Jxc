module CommonV1APIHelper

  #创建一个订单编码
  def CommonV1APIHelper.create_orderno

    time = Time.now
    return time.strftime("%Y%m%d%H%M%S") + time.usec.to_s
  end

end