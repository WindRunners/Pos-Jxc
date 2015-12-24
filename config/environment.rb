# Load the Rails application.
require File.expand_path('../application', __FILE__)



module ProductConfig
  DYNAMIC_FIELDS = Hash.new
end

module RestConfig
  IMG_SERVER = 'http://www.nit.cn:3001/'

  #PRODUCT_SERVER = 'http://localhost:3001/'
  PRODUCT_SERVER = ENV["PHOTO_HOST"] || 'http://10.99.99.206:3001/'

  COUSTOMER_SERVER = 'http://10.99.99.206:82/'
end

# Initialize the Rails application.
Rails.application.initialize!