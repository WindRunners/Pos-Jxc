# Load the Rails application.
require File.expand_path('../application', __FILE__)



module ProductConfig
  DYNAMIC_FIELDS = Hash.new
end

module RestConfig
  IMG_SERVER = 'http://pic.ibuluo.me:3001/'

  #PRODUCT_SERVER = 'http://localhost:3001/'
  PRODUCT_SERVER = ENV["PHOTO_HOST"] || 'http://pic.ibuluo.me:3001/'

  COUSTOMER_SERVER = 'http://jyd.ibuluo.me:3000/'
end

# Initialize the Rails application.
Rails.application.initialize!