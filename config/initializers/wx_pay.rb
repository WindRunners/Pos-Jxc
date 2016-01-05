# required
WxPay.appid = 'wxb5e0d65f99e90a18'
WxPay.key = 'ppVBtFzX72LjTUZg8brxsc9frj6LDs49'
WxPay.mch_id = '1302566301'


WxPay.set_apiclient_by_pkcs12(File.read("#{Rails.root}/config/cert/wx_cert.p12"), WxPay.mch_id)


# optional - configurations for RestClient timeout, etc.
WxPay.extra_rest_client_options = {
    timeout: 10, open_timeout: 10, verify_ssl: OpenSSL::SSL::VERIFY_NONE
}
