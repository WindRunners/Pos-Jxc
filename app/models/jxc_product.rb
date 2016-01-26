class JxcProduct < ActiveResource::Base
  self.site = 'http://pic.xianglema.cn:3001/'
  self.element_name = 'product'
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
