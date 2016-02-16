class JxcSetting
  def self.current=(user)
    Thread.current[:user]=user
  end

  def self.current_user
    Thread.current[:user]
  end
end