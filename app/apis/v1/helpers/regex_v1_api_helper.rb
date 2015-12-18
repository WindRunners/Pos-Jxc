module RegexV1APIHelper

  #手机号码验证
  def RegexV1APIHelper.mobile(mobile)

    mobile.present? && !mobile.match(/^\d{11}$/).nil?
  end


  #验证码
  def RegexV1APIHelper.verifycode(verifycode)

    verifycode.present? && !verifycode.match(/^\d{6}$/).nil?
  end
end