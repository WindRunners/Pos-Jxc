module AnnouncementV1APIHelper

  #验证announcement是否存在
  def AnnouncementV1APIHelper.announcement_if_exist(announcement_id)
    Announcement.all.include? Announcement.find(announcement_id)
  end

end