class Ahoy::Store < Ahoy::Stores::FluentdStore
  # customize here

  def track_event(name, properties, options)
    super do |event|
      event[:ip] = request.remote_ip if request.present?
    end
  end

  def exclude?
    ENV["RAILS_ENV"] != "production"
  end

  def logger
    @logger ||= AHOY::LOGGER
  end
  
end
