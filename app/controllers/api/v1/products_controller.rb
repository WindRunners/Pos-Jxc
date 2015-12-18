class Api::V1::ProductsController < Api::V1::BaseController
  def index

    puts "sending sms"

    ChinaSMS.use :yunpian, password: '9525738f52010b28d1b965e347945364'

    # 通用接口
    ChinaSMS.to '18638293566', '【酒运达】您的验证码是3313'

    respond_with(Product.all)
  end

  def create

    product = Product.new(product_params)
    if product.save
      respond_with(product, :location => api_v1_product_path(product))
    else
      respond_with(product)
    end
  end

  def show
    product = Product.find(params[:id])



    respond_with(product)
  end

  def find
    product = Product.find( qrcode: params[:qrcode])
    respond_with(product)
  rescue ActiveRecord::RecordNotFound
    error = { :error => "The product you were looking for could not be found."}
    respond_with(error, :status => 404)

  end

  private

  def product_params
    params.require(:product).permit(:name,:title,:description,:qrcode)
  end

end