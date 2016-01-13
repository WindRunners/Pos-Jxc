class CommonController < ApplicationController

  def create_qrcode_image

    qrcode_url = params[:qrcode_url].present? ? params[:qrcode_url] : 'http://fir.im/hnjyd'
    qrcode = RQRCode::QRCode.new(qrcode_url)
    png = qrcode.as_png(
        resize_gte_to: false,
        resize_exactly_to: false,
        fill: 'white',
        color: 'black',
        size: 200,
        border_modules: 0,
        module_px_size: 6
    )
    send_data(png.to_datastream,:type=>'image/png', :disposition => "inline")
  end


end
