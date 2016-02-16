# Load the Rails application.
require File.expand_path('../application', __FILE__)



module ProductConfig
  DYNAMIC_FIELDS = Hash.new
end

module RestConfig
  PRODUCT_SERVER = 'http://pic.jiuyunda.net:3001/'

  CUSTOMER_SERVER = ENV["CUSTOMER_HOST"] || 'http://customer.jiuyunda.net:3000/'

  OA_SERVER = 'http://www.ibuluo.me:9090/'

  ELEPHANT_HOST = ENV["ELEPHANT_HOST"] || 'http://www.jiuyunda.net:90/'

end

module AHOY
  LOGGER = Fluent::Logger::FluentLogger.new("elephant", host: ENV["FLUENTD_HOST"] || "localhost", port: ENV["FLUENTD_PORT"] || 24224)
end

# Initialize the Rails application.
Rails.application.initialize!