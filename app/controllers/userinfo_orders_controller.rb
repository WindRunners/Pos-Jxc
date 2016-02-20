class UserinfoOrdersController < ApplicationController
  before_action :set_order, only: [:update, :destroy]

  skip_before_action :authenticate_user!, only: [:wx_notify, :alipay_notify,:getcode,:binduserinfo]



  def wx_notify
    result = Hash.from_xml(request.body.read)["xml"]

    payment = WxPayment.new(result)
    payment.save!

    order = UserinfoOrder.find(params[:id])

    if order.state == 1 then
      render :xml => {return_code: "SUCCESS"}.to_xml(root: 'xml', dasherize: false)
      return
    end

    if WxPay::Sign.verify?(result)

      logger.info result

      if order.state == 0 && order.paymode == 2 then
        order.payment_order!
        render :xml => {return_code: "SUCCESS"}.to_xml(root: 'xml', dasherize: false)
        return
      end

      render :xml => {return_code: "FAIL", return_msg: "签名失败"}.to_xml(root: 'xml', dasherize: false)
    else
      render :xml => {return_code: "FAIL", return_msg: "签名失败"}.to_xml(root: 'xml', dasherize: false)
    end
  end

  def alipay_notify


    order_id = params.delete(:id)

    payment = AlipayPayment.new(alipay_payment_params)
    payment.save!

    order = UserinfoOrder.find(order_id)

    if order.state == 1 then
      render plain: "success"
      return
    end

    notify_params = params.except(*request.path_parameters.keys)

    if Alipay::Notify.verify?(notify_params)
      logger.info "verify success"

      if order.state == 0 && order.paymode == 1 then
        order.payment_order!
        render plain: "success"
        return
      end

      render plain: "fail"
    else
      logger.info "verify fail"
      render plain: "fail"
    end
  end

  def getcode

    url_r = 'https://api.weixin.qq.com/sns/oauth2/access_token?'
    url_end= '&grant_type=authorization_code'
    appid= 'wx5950970145118999'
    secret= '333c9d0287c88a8c9aad6a2c55364925'
    code=params[:code] || code=""
    url = url_r+"appid="+appid+"&secret="+secret+"&code="+code+url_end
    response = RestClient.get(url)
    if response.code==200 #40029
      response_json=JSON.parse(response.body)
      Rails.logger.info "-----------------------=====#{url}============="
      Rails.logger.info "-----------------------=====#{response_json}============="
        if response_json["errcode"].present?
          @error_msg = '请退回公证号重新点击‘商家绑定’在操作'
        else
          @openid = response_json["openid"]
           # session[:id]=response_json["openid"]
        end
    end
    render layout: false
  end

  def binduserinfo

    @mobile = params[:mobile] #管理员账号，即各单位的初始化用户
    password = params[:password] #管理员密码
    @openid = params["openid"]
    admin_user = User.where({'mobile' => @mobile}).first

    if !admin_user.present?

      @error_msg = '当前账号不存在，请重新输入！'
      render "getcode",layout:false
      return
    end

    if admin_user.user_flag != 1
      @error_msg = '当前账号不存在，请重新输入！'
      render "getcode",layout:false
      return
    end

    if BCrypt::Password.new(admin_user.encrypted_password)!=password
      @error_msg = '当前密码不正确，请重新输入！'
      render "getcode",layout:false
      return
    end


    @userinfo = Userinfo.find(admin_user['userinfo_id'])
    if @userinfo.update(:openid => @openid)
      @success_msg = "恭喜您绑定成功！</br> #{@userinfo.shopname}"
    else
      @error_msg = "绑定失败，信息为：#{@userinfo.errors.full_messages.join("</br>")}！"
    end
    render "getcode",layout:false
  end

  def bind_form

  end


  private
  # Use callbacks to share common setup or constraints between actions.
  def set_order
    @order = Order.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def order_params
    params.require(:order).permit(:orderno, :ordertype, :orderstatus, :modifymark, :consignee, :address, :telephone, ordergoods_attributes: [:quantity])
  end

  def alipay_payment_params
    params.permit(:discount, :payment_type, :subject, :trade_no, :buyer_email,
         :gmt_create, :notify_type, :out_trade_no, :seller_id, :notify_time, :body, :trade_status, :is_total_fee_adjust,
         :total_fee, :gmt_payment, :seller_email, :price, :buyer_id, :notify_id, :use_coupon, :sign_type, :sign)
  end
end
