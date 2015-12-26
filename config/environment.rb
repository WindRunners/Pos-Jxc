# Load the Rails application.
require File.expand_path('../application', __FILE__)



module ProductConfig
  DYNAMIC_FIELDS = Hash.new
end

module RestConfig
  IMG_SERVER = 'http://pic.ibuluo.me:3001/'

  #PRODUCT_SERVER = 'http://localhost:3001/'
  PRODUCT_SERVER = ENV["PHOTO_HOST"] || 'http://pic.ibuluo.me:3001/'

  CUSTOMER_SERVER = 'http://jyd.ibuluo.me:3000/'
end

module AHOY
  LOGGER = Fluent::Logger::FluentLogger.new("elephant", host: ENV["FLUENTD_HOST"] || "localhost", port: ENV["FLUENTD_PORT"] || 24224)
end

# Initialize the Rails application.
Rails.application.initialize!