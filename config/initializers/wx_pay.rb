# required

# WxPay.appid = 'wxaea14673830a255a'
# WxPay.key = 'Pm0B93TUiK23H7UYg3bGeR4afzHaVZvh'
# WxPay.mch_id = '1283359101'


#酒运达dfj－－－－－－－－》
# WxPay.appid = 'wx5950970145118999'
# WxPay.key = 'asd4521asdfSDF21AOD32Dzf5aZDdfwe'
# WxPay.mch_id = '1264577401'
#酒运达dfj－－－－－－－－》

WxPay.appid = 'wxb5e0d65f99e90a18'
WxPay.key = 'ppVBtFzX72LjTUZg8brxsc9frj6LDs49'
WxPay.mch_id = '1302566301'

WxPay.set_apiclient_by_pkcs12(File.read("#{Rails.root}/config/cert/wx_cert.p12"), WxPay.mch_id)


# optional - configurations for RestClient timeout, etc.
WxPay.extra_rest_client_options = {
    timeout: 10, open_timeout: 10, verify_ssl: OpenSSL::SSL::VERIFY_NONE
}
