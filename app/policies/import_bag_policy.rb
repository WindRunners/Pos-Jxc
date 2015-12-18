class ImportBagPolicy < ApplicationPolicy

  #审核处理保存权限
  def deal?

    current_state = get_current_state

    return true if current_state=='new' && current_user.id == record.user.id

    return true if current_state=='first_check' && canFirstCheck?

    return true if current_state=='second_check' && canSecondCheck?

    return false
  end


  #审核列表验证
  def deal_list?

    canFirstCheck? || canSecondCheck?
  end

  #修改权限验证
  def update?

    # puts "更新验证,当前节点:#{record.current_state.to_s},名称 :#{record.current_state.name.to_s},验证 :#{record.current_state.name.to_s == "new"}"
    current_state = get_current_state
    record['user_id'] == current_user.id && current_state=='new'
  end

  #删除权限验证
  def destroy?
    record['user_id'] == current_user.id && !record.current_state.present?
  end

  #发起审核权限
  def start?
    record['user_id'] == current_user.id && get_current_state == 'new'
  end

  #一级审核
  def canFirstCheck?
    hasFirstCheckRole? && get_current_state == 'first_check'
  end

  #二级审核
  def canSecondCheck?
    hasSecondCheckRole? && get_current_state == 'second_check'
  end


  #一级审核
  def hasFirstCheckRole?
    @current_user.has_role? :manager
  end

  #二级审核
  def hasSecondCheckRole?
    @current_user.has_role? :finance
  end


  private

  def get_current_state
    record.current_state.present? ? record.current_state.name.to_s : 'new'
  end

end