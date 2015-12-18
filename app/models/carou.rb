class Carou < ActiveResource::Base
  self.site = 'http://10.99.99.206/'
  self.element_name = 'carousel'
  self.headers["appkey"] = 'LARK'

  def self.carouCache
    #Rails.cache.fetch("Business.all") { all }
    all
  end
end
