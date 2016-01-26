module Entities
  class Announcement < Grape::Entity
    expose :id, documentation: {type: String, desc: '公告id'}
    expose :title, documentation: {type: String, desc: '标题'}
    expose :read_num, documentation: {type: Integer, desc: '阅读量'}
    # expose :is_top, documentation: {type: Integer, desc: '是否置顶'}
    # expose :sequence, documentation: {type: Integer, desc: '排序字段'}
    expose :source, documentation: {type: String, desc: '来源'}
    expose :pic_path, documentation: {type: Array, desc: '列表图片路径数组'} do |announcement, options|
      if announcement.pic_thumb_path.present? && !announcement.pic_thumb_path.empty?
        announcement.pic_path = announcement.pic_thumb_path
      else
        announcement.pic_path = announcement.pic_path
      end
    end
    # expose :announcement_category_id, documentation: {type: String, desc: '分类ID'}
    expose :created_at, documentation: {type: String, desc: '创建时间'} do |announcement, options|
        announcement.created_at =announcement.created_at.strftime("%Y-%m-%d %H:%M")
      end
  end
end