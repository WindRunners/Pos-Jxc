class ApiLogger < Grape::Middleware::Base

  def current_user
    token = headers['Authentication-Token']
    @current_user = User.find_by(authentication_token: token)
  rescue
  end


  def ahoy
    @ahoy ||= Ahoy::Tracker.new
  end

  def before
    start_time

    ahoy.track "api-begin", request_parameters
  end

  def after
    stop_time
    ahoy.track "api-end", response_parameters
    nil
  end

  protected

  def request_parameters
    {
        path: request.path,
        params: request.params.to_hash,
        method: request.request_method,
        #db: @db_duration.round(2)
    }
  end

  def response_parameters
    {
        path: request.path,
        params: request.params.to_hash,
        method: request.request_method,
        total: total_runtime,
        #db: @db_duration.round(2),
        status: response.status
    }
  end

  def request
    @request ||= ::Rack::Request.new(env)
  end

  def total_runtime
    ((stop_time - start_time) * 1000).round(2)
  end

  def start_time
    @start_time ||= Time.now
  end

  def stop_time
    @stop_time ||= Time.now
  end

end