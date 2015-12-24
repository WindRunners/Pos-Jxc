class Customer  <  ActiveResource::Base
  self.site = RestConfig::COUSTOMER_SERVER

  def self.find_by_mobile(mobile)
    find(:first, :params => {:mobile => mobile})
  end
end