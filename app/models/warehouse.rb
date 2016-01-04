module Warehouse
  class Product < ActiveResource::Base
    self.site = "http://pic.ibuluo.me:3001/"
    #self.site = "http://localhost:3001/"

    self.headers['Authorization'] = 'Token token="564ec5f4c3666e5c6b000000"'

    add_response_method :http_response

    def exists? (current_user)
      begin
        ::Product.shop(current_user).find(self.id)
        return true
      rescue
        return false
      end
    end
  end

  class MobileCategory < ActiveResource::Base
    self.site = "http://pic.ibuluo.me:3001/"
    #self.site = "http://localhost:3001/"

    self.headers['Authorization'] = 'Token token="564ec5f4c3666e5c6b000000"'

    def self.JYD
      MobileCategory.where(tag:'JYD')
    end
  end

  class Promotion < ActiveResource::Base
    self.site = "http://pic.ibuluo.me:3001/"
    # self.site = "http://localhost:3001/"

    self.headers['Authorization'] = 'Token token="564ec5f4c3666e5c6b000000"'
  end

  class Notice < ActiveResource::Base
    self.site = "http://pic.ibuluo.me:3001/"
    #self.site = "http://localhost:3001/"

    self.headers['Authorization'] = 'Token token="564ec5f4c3666e5c6b000000"'
  end
end