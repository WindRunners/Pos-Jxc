#
# 用于管理其他 model 的 排序码
#
class BuilderSort
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Multitenancy::Document

  tenant :client

  field :model
  field :current, type: Integer, default: 1

  class << self
    #
    # 创建一个新的计数器，并将计数器加一
    #
    def build(model)
      item = find_entry(normalize_arg(model))
      Rails.logger.info "class:#{item}"
      sort = item.current
      Rails.logger.info "current:#{sort}"
      item.update(current: sort + 1)
      sort
    end

    #
    #更新当前排序码
    #
    def update(model)

    end

    #
    # 重置计数器为 1
    #
    def reset(model)
      find_entry(normalize_arg(model)).update(current: 1)
    end

    #
    # 返回当前计数器的值
    #
    def current(model)
      Rails.logger.info "current:#{model}"
      find_entry(normalize_arg(model)).current
    end

    #
    # 找到相应的记录，没找到则创建一个
    #
    def find_entry(model)
      current_user= JxcSetting.current_user
      if current_user.present? && current_user.userinfo.present?
        client_instance = Client.where(:userinfo => current_user.userinfo, :aasm_state => "starting").first
        Rails.logger.info "init_db::client_instance::#{client_instance}"
      end
      if client_instance.present?
        return find_or_create_by(:model => normalize_arg(model),:client_id=>client_instance.id)
      else
        return find_or_create_by(:model => normalize_arg(model))
      end
    end

    #
    # 将参数统一转成大写字母开头的字符串
    #
    # normalize_arg(:post)	# => 'Post'
    #
    def normalize_arg(model)
      Rails.logger.info "normalize_arg======#{model}:::::#{model.class}"
      model.to_s
    end
  end
end
