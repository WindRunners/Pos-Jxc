class Customer  <  ActiveResource::Base
  self.site = "http://10.99.99.206:82/"
  # self.site = "http://localhost:3001/"

  def self.find_by_mobile(mobile)
    find(:first, :params => {:mobile => mobile})
  end
end