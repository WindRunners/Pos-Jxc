# required
WxPay.appid = 'wxaea14673830a255a'
WxPay.key = 'Pm0B93TUiK23H7UYg3bGeR4afzHaVZvh'
WxPay.mch_id = '1283359101'


#WxPay.apiclient_cert_path = File.read("#{Rails.root}/config/cert/wx_cert.p12")


# optional - configurations for RestClient timeout, etc.
WxPay.extra_rest_client_options = {
    timeout: 10, open_timeout: 10, verify_ssl: OpenSSL::SSL::VERIFY_NONE
}
