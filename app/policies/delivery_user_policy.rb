class DeliveryUserPolicy

  class Scope
    attr_reader :current_user, :scope

    def initialize(current_user, scope)
      @current_user = current_user
      @scope = scope
    end

    def resolve

      whereParams = {}
      whereParams['mobile'] = /#{scope.mobile}/ if scope.mobile.present?
      whereParams['status'] = scope.status if scope.status.present?

      #puts "参数为:#{whereParams.to_json}"

      if current_user.has_any_role? :SuperAdmin #显示未审核的配送员
        scope.class.where(whereParams)
      else #显示当前城市下面的配送员
        whereParams['userinfo_id'] = current_user['userinfo_id']
        scope.class.where(whereParams)
      end
    end
  end

  def isSuperAdmin?
    @current_user.has_role? :SuperAdmin
  end

end