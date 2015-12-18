class Splash < ActiveResource::Base
  self.site = 'http://10.99.99.206/'
  self.element_name = 'splash_screen'
  self.headers["appkey"] ='LARK'

  def self.splashCache
    #Rails.cache.fetch("Business.all") { all }
    all
  end
end
