module Entities
  class Announcement < Grape::Entity
    expose :id, documentation: {type: String, desc: '公告id'}
    expose :title, documentation: {type: String, desc: '标题'}
    expose :content, documentation: {type: String, desc: '正文'}
    expose :description, documentation: {type: String, desc: '描述'}
    expose :author, documentation: {type: String, desc: '作者'}
    expose :read_num, documentation: {type: Integer, desc: '阅读量'}
    expose :is_top, documentation: {type: Integer, desc: '是否置顶'}
    expose :sequence, documentation: {type: Integer, desc: '排序字段'}
    expose :source, documentation: {type: String, desc: '来源'}
    expose :pic_path, documentation: {type: String, desc: '图片路径数组'}
    expose :release_time, documentation: {type: String, desc: '第三发发布时间'}
    expose :announcement_category_id, documentation: {type: String, desc: '分类ID'}
    expose :created_at, documentation: {type: String, desc: '创建时间'}
  end
end