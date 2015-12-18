class Ahoy::Store < Ahoy::Stores::FluentdStore
  # customize here

  def track_event(name, properties, options)
    super do |event|
      event[:ip] = request.remote_ip if request.present?
    end
  end

  def exclude?
    ENV["RAILS_ENV"] == "test" or ENV["RAILS_ENV"] == "development"
  end

  def logger
    @logger ||= Fluent::Logger::FluentLogger.new("elephant", host: ENV["FLUENTD_HOST"] || "localhost", port: ENV["FLUENTD_PORT"] || 24224)
  end
end
