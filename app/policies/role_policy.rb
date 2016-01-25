class RolePolicy < ApplicationPolicy
  def canEdit?
    @current_user.has_any_role? :supervisor,:admin
  end

  def canDelete?
    @current_user.has_any_role? :admin
  end

  def canCategory?
    @current_user.has_any_role? :admin
  end

  def canAudit?
    @current_user.has_role? :supervisor
  end

  def canAssignMe?
    @current_user.has_role? :designer
  end

  def canAssign?
    @current_user.has_role? :supervisor
  end

end