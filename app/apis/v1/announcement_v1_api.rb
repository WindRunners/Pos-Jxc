require 'grape'
require 'helpers/announcement_v1_api_helper'

class AnnouncementV1API < Grape::API
  format :json

  include AnnouncementV1APIHelper

  desc '分页获取' do
    success Entities::Announcement
  end
  params do
    requires :announcement_category_id, type: String, desc: '分类ID'
    requires :page, type: String, desc: '当前页'
    requires :per_page, type: String, desc: '每页纪录数目'
  end
  get 'list' do
    announcement_category_id = params[:announcement_category_id]
    present Announcement.where(:status => 1, :announcement_category_id => announcement_category_id).page(params[:page]).per(params[:per_page]), with: Entities::Announcement
    # present Announcement.all.skip(params[:page]*params[:per_page]).limit(params[:page]),with: Entities::Announcement
  end


  desc '增加单条' do
    success Entities::Announcement
  end
  params do
    requires :title, type: String, desc: '标题'
    requires :content, type: String, desc: '正文'
    requires :description, type: String, desc: '描述'
    requires :author, type: String, desc: '作者'
    requires :read_num, type: Integer, desc: '阅读量'
    requires :is_top, type: Integer, desc: '是否置顶,#0：默认，1：置顶，－1:不置顶'
    requires :sequence, type: Integer, desc: '排序字段'
    requires :news_url, type: String, desc: '链接'
    requires :source, type: String, desc: '来源'
    requires :announcement_category_id, type: String, desc: '分类ID'
  end
  post 'one' do
    announcement = Announcement.new(title: params[:title], content: params[:content], description: params[:description], author: params[:author], is_top: params[:is_top], sequence: params[:sequence], news_url: params[:news_url], source: params[:source])
    if announcement.save
      announcement
    else
      {error: announcement.errors.full_messages}
    end
  end

  desc '批量生成'

  params do
    requires :batch_array, type: String, desc: 'JSON格式的Array嵌套Hash'
    requires :announcement_category_id, type: String, desc: '分类ID'
  end

  post 'batch' do
    batch_array_str = params[:batch_array]
    batch_array =JSON.parse(batch_array_str)
    batch_array.each do |x|
      announcement = Announcement.new
      announcement.title = x['title']
      announcement.content = x['content']
      if announcement.save
        announcement
      else
        {error: announcement.errors.full_messages}
      end
    end
  end


  desc '详细页面'

  params do
    requires :announcement_id, type: String, desc: 'announcement_id'
    # requires :user_id, type: Integer, desc: 'user_id'
  end

  get 'app_show' do
    announcement = Announcement.where(:status => 1).find(params[:announcement_id])
    user_id = '未知游客'
    if !user_id.nil?
      announcement.reader << user_id
    end
    announcement.read_num = announcement.read_num+1
    announcement.save
    showHash = Hash.new()
    showHash[:id] = announcement.id
    showHash[:title] = announcement.title
    showHash[:read_num] = announcement.read_num
    showHash[:url] = 'http://10.99.99.206:81/announcements/' + announcement.id + '/app_show'
    showHash
  end

  desc '获取分类'
  get 'category' do
    category = AnnouncementCategory.all
    category
  end


  desc '验证是否存在'
  params do
    requires :announcement_id, type: String, desc: 'announcement_id'
    # requires :user_id, type: Integer, desc: 'user_id'
  end
  get 'validate' do
    AnnouncementV1APIHelper.announcement_if_exist(params[:announcement_id])
  end

end