class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #protect_from_forgery with: :exception

  include Pundit

  before_action :authenticate_user!

  before_action :configure_permitted_parameters, if: :devise_controller?

   # before_action :authenticate_userinfo

  after_filter :track_action

  rescue_from ::Exception, with: :error_occurred

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :mobile
    devise_parameter_sanitizer.for(:sign_in) << :mobile
  end

  def track_action
    ahoy.track "Processed #{controller_name}##{action_name}", request.filtered_parameters
  end

  def append_info_to_payload(payload)
    super
    payload[:request_id] = request.uuid
    payload[:user_id] = current_user.id if current_user
    payload[:visit_id] = ahoy.visit_id # if you use Ahoy
  end

  def error_occurred(exception)
    ahoy.track "exception", {'exception' => exception, 'backtrace' => exception.backtrace}
    raise
  end

  # def authenticate_userinfo
  #   if current_user.step ==1
  #     redirect_to :controller => "userinfos" ,action: "index", :is_redirect_to => true if params[:is_redirect_to].blank?
  #   elsif current_user.step ==3
  #     redirect_to :controller => "userinfos" ,action: "index", :is_redirect_to => true if params[:is_redirect_to].blank?
  #     current_user.step =4
  #   end
  # end

  def authenticate_user!
    token, options = ActionController::HttpAuthentication::Token.token_and_options(request)

    super unless token == 'rbMmEeoH8RxRDyN24PQv'
  end



  def sendMessage(mobile)
    @codestr = [('a'..'z'),('0'..'9')].map{|i| i.to_a}.flatten
    code = (0..3).map{ @codestr[rand(@codestr.length)] }.join

    ChinaSMS.use :yunpian, password: '9525738f52010b28d1b965e347945364'


    ChinaSMS.to mobile, "【酒运达】您的验证码是#{code}。如非本人操作，请忽略本短信"

    code
  end


  def render_js(path, notice = '')

    flash[:notice] = notice if notice.present?

    render :text => "location.hash = '##{path}|hash#{rand(1000)}'"

  end

  def stringParseDate(string)
    begin
      date = Date.strptime(string,'%m/%d/%Y')
    rescue
      date = Time.now.to_date
    end
    return date
  end


end
