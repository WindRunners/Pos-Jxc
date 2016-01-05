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
    appid= 'wxbfdca48f1ab5ddf9'
    secret= '518547e84859422c443ee645075acc48'
    code=params[:code] || code=""
    url = url_r+"appid="+appid+"&secret="+secret+"&code="+code+url_end
    response = RestClient.get(url)
    if response.code==200 #40029
      response_json=JSON.parse(response.body)
      Rails.logger.info "-----------------------=====#{url}============="
      Rails.logger.info "-----------------------=====#{response_json}============="
        if response_json["errcode"].present? && response_json["errcode"]==40029
          flash[:error]="请退回公证号重新点击‘绑定商户’在操作"
          render '/userinfo_orders/getcode',layout: false
        else
           session[:id]=response_json["openid"]
        end
    end
    render layout: false
  end

  def binduserinfo
    if params[:check_user].present?
      begin
        @user=User.find_by(mobile: params[:user_mobile])
        if  @user.userinfo.name==params[:user_name]

          session[:code] = sendMessage(@user.mobile)
          logger.info session[:code]
          render "bind_form",layout:false
        else
          raise StandardError
        end
      rescue
        respond_to do |format|
          flash[:error]="用户电话或姓名不存在,请查证"
          format.html{render 'getcode',layout: false}
        end
      end
      # render "bind_form",layout:false
    end

    if params[:check_mesage].present?
      begin
        @userinfo = Userinfo.find(params[:check_info])
        if session[:code] == params[:mesage]
          @userinfo.update(:wx_name => params[:wx_name],:openid => session[:id])
          session[:id]=""
          session[:code]=""
        else
          flash[:error]="验证码有误！！"
          render "bind_form",layout:false
        end
        render "binduserinfo",layout:false
      rescue
      end

    end

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
