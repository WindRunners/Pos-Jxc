class UserPolicy
  attr_reader :current_user, :model

  def initialize(current_user, model)
    @current_user = current_user || User.new
    @user = model
  end

  def isAdmin?
    @current_user.has_role? :admin
  end

  def show?
    @current_user.has_role? :admin or @current_user == @user
  end

  def update?
    @current_user.has_role? :admin
  end

  def destroy?
    return false if @current_user == @user
    @current_user.has_role? :admin
  end

end