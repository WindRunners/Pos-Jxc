class Customer  <  ActiveResource::Base
  self.site = RestConfig::CUSTOMER_SERVER

    def self.find_by_mobile(mobile)
      find(:first, :params => {:mobile => mobile})
    end
end