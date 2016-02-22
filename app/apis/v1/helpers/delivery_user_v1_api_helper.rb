module DeliveryUserV1APIHelper

  REGISTER_VERIFYCODE_PREFIX = "deliveryUserRegister" #定义配送员注册验证码前缀
  EXPIRY_TIMES = 60000 #验证码失效时间10分钟

  #配送员注册
  def DeliveryUserV1APIHelper.register(deliveryUser, verifycode)

    begin

      puts "配送员:#{deliveryUser.to_json}"

      verifycode2 = VerifyCode.where(key: "#{REGISTER_VERIFYCODE_PREFIX}_#{deliveryUser.mobile}").first #获取配送员注册验证码
      if !verifycode2.present?
        return {msg: '验证码不存在,请重新获取', flag: 0}
      elsif verifycode2.code != verifycode #验证码不一致
        return {msg: '验证码错误,请重新输入', flag: 0}
      elsif Time.now - verifycode2["updated_at"] > EXPIRY_TIMES #有效期一分钟
        return {msg: '验证码失效,请重新获取', flag: 0}
      end

      if deliveryUser.save

        verifycode2.delete #删除验证码
        deliveryUser.set_delivery_user_track
        deliveryUser.save #再次更新
        deliveryUser
      else
        {msg: deliveryUser.errors.full_messages, flag: 0}
      end
    rescue Exception => e #异常捕获
      puts e.message
      return {msg: '服务器端出现异常', flag: 0}
    end
  end


  #配送员登录
  def DeliveryUserV1APIHelper.login(mobile, verifycode, channel)

    begin

      deliveryUser = DeliveryUser.where(mobile: mobile).first #根据用户名查询配送员数据

      return {msg: '当前手机号未注册,请注册!', flag: 0} if !deliveryUser.present?

      if mobile != "18224529355" #测试账号

        return {msg: '验证码错误,请重新获取!', flag: 0} if !deliveryUser.verify_codes.present? || !deliveryUser.verify_codes["login"].present?

        verifycode2 = deliveryUser.verify_codes["login"]["code"].to_s
        time = deliveryUser.verify_codes["login"]["time"]

        #判断配送员是否已经审核通过
        if deliveryUser.status != 1
          return {msg: '当前配送员未审核通过，请耐心等待审核!', flag: 0}
        elsif verifycode != verifycode2 #判断验证码是否一致
          return {msg: '验证码错误,请重新获取!', flag: 0}
        elsif Time.now - time > EXPIRY_TIMES #有效期10分钟
          return {msg: '验证码失效,请重新获取!', flag: 0}
        end
      end

      deliveryUser.push_channels.find_or_create_by(channel_id: channel) if channel.present?


      deliveryUser.set_delivery_user_track
      deliveryUser.save #更新配送员登录信息
      deliveryUser
    rescue Exception => e #异常捕获
      puts e.message
      return {msg: '服务器端出现异常', flag: 0}
    end
  end


  #获取登录验证码
  def DeliveryUserV1APIHelper.get_login_verifycode(mobile,type)

    begin


      deliveryUser = DeliveryUser.where(mobile: mobile).first #根据用户名查询配送员数据

      return {msg: '当前手机号未注册,请注册!', flag: 0} if !deliveryUser.present?

      veriycode = DeliveryUserV1APIHelper.create_veriycode #生成验证码

      #发送验证码,并更新验证码信息
      if !deliveryUser.verify_codes.present? #验证码都为nil
        deliveryUser.verify_codes = {login: {code: veriycode, time: Time.now}}
      else
        deliveryUser.verify_codes["login"] = {code: veriycode, time: Time.now}
      end
      deliveryUser.save #保存对象

      ChinaSMS.use :yunpian, password: '9525738f52010b28d1b965e347945364'

      if type == 'sms'
        # 通用接口
        ChinaSMS.to mobile, '【酒运达】您的配送端登录验证码是'+veriycode
      else
        ChinaSMS.voice mobile, veriycode
      end

      {msg: '验证码已发送,请稍后...', flag: 1,data: veriycode}
    rescue Exception => e #异常捕获
      puts e.message
      return {msg: '服务器端出现异常', flag: 0}
    end

  end

  #获取注册验证码
  def DeliveryUserV1APIHelper.get_register_verifycode(mobile,type)

    begin

      deliveryUser = DeliveryUser.where(mobile: mobile).first #根据用户名查询配送员数据
      return {msg: '当前手机号已注册,请直接登录', flag: 0} if deliveryUser.present?

      veriycode = DeliveryUserV1APIHelper.create_veriycode #生成验证码
      veriycode2 = VerifyCode.where(key: "#{REGISTER_VERIFYCODE_PREFIX}_#{mobile}").first #获取配送员注册验证码

      if veriycode2.present?
        veriycode2.code = veriycode
      else
        veriycode2 = VerifyCode.new(key: "#{REGISTER_VERIFYCODE_PREFIX}_#{mobile}", code: veriycode)
      end

      #更新验证码
      veriycode2.save
      ChinaSMS.use :yunpian, password: '9525738f52010b28d1b965e347945364'

      if type == 'sms'
        # 通用接口
        ChinaSMS.to mobile, '【酒运达】您的配送端注册验证码是' + veriycode
      else
        ChinaSMS.voice mobile, veriycode
      end

      {msg: '验证码已发送,请稍后...', flag: 1,data: veriycode}
    rescue Exception => e #异常捕获
      puts e.message
      return {msg: '服务器端出现异常', flag: 0}
    end
  end

  private

  #创建验证码
  def DeliveryUserV1APIHelper.create_veriycode

    code = ''
    for i in 0..5
      code.concat(rand(9).to_s)
    end
    return code
  end


end