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
  end


  desc '详细页面'

  params do
    requires :announcement_id, type: String, desc: 'announcement_id'
    # requires :user_id, type: Integer, desc: 'user_id'
  end

  get 'app_show' do
    announcement = Announcement.where(:status => 1).find(params[:announcement_id])
    customer_id = '未知游客'
    if !customer_id.nil?
      announcement.reader << customer_id
    end
    announcement.read_num = announcement.read_num+1
    announcement.save
    showHash = Hash.new()
    showHash[:id] = announcement.id
    showHash[:title] = announcement.title
    showHash[:read_num] = announcement.read_num
    showHash[:url] = 'http://jyd.ibuluo.me:4000/announcements/' + announcement.id + '/app_show'
    showHash
  end

  desc '获取分类'
  get 'category' do
    category = AnnouncementCategory.all
    category
  end


  desc '增加评论'

  params do
    requires :announcement_id, type: String, desc: 'announcement_id'
    requires :customer_id, type: String, desc: 'customer_id'
    requires :content, type: String, desc: 'content'
  end


  post 'add_comment' do
    @announcement = Announcement.find(params[:announcement_id])
    @chateau_comment = @announcement.chateau_comments.build();
    @chateau_comment.content = params[:content]
    @chateau_comment.customer_id = current_customerUser.id
    @chateau_comment.save
    data ={}
    if @chateau_comment.save
      data['flag'] = 1
      data['message'] = '保存成功！'

    else
      data['flag'] = 0
      data['message'] = '保存失败！'
    end
    data
  end




  desc '收藏快讯'

  params do
    requires :announcement_id, type: String, desc: 'announcement_id'
    requires :customer_id, type: String, desc: 'customer_id'
  end


  post 'stow' do
    @announcement = Announcement.find(params[:announcement_id])
    @announcement.customer_ids << current_customerUser.id
    data ={}
    if @announcement.save
      data['flag'] = 1
      data['message'] = '收藏成功！'

    else
      data['flag'] = 0
      data['message'] = '收藏失败！'
    end
    data
  end

  desc '收藏快讯列表'

  params do
    requires :customer_id, type: String, desc: 'customer_id'
  end


  post 'stow_list' do
    present Announcement.where({"status"=>"1","customer_ids"=>params[:customer_id]}),with: Entities::Announcement
  end

end