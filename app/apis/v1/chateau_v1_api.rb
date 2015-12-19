require 'grape'
require 'helpers/chateau_v1_api_helper'

class ChateauV1API < Grape::API
  format :json
  #嵌入帮助类
  include   ChateauV1APIHelper

  desc '所有' do
    success Entities::Chateau
  end
  params do
    requires :page, type: String, desc: '当前页'
    requires :per_page, type: String, desc: '每页纪录数目'
  end
  get 'all' do
    present Chateau.all.page(params[:page]).per(params[:per_page]), with: Entities::Chateau
  end


  desc '详细'

  params do
    requires :chateau_id, type: String, desc: 'chateau_id'
  end

  get 'show' do
    @chateau = Chateau.find(params[:chateau_id])
    data = {}
    # 酒庄基本属性
    data['chateau'] = @chateau
    # 详细H5页面地址
    data['introduce'] = '/chateaus/'+@chateau.id+'/introduce_show'
    # 标签
    mark_array = []
    @chateau.chateau_marks.each do |m|
      mark_hash = {}
      mark_hash[m.name] = m.value
      mark_array << mark_hash
    end
    data['mark'] = mark_array
    # 轮播图地址数组
    pic_array = []
    @chateau.pictures.limit(5).each do |p|
      pic_array << p.pic.url
    end
    data['pic'] = pic_array
    #酒庄拥有的酒款
    data['wines'] = @chateau.wines
    data
  end


  desc 'chateau_list'

  params do
    requires :region_id, type: String, desc: 'region_id'
    # requires :page, type: String, desc: '当前页'
    # requires :per_page, type: String, desc: '每页纪录数目'
  end

  get 'chateau_list' do
    region_id = params[:region_id]
    ChateauV1APIHelper.chateau_list(region_id)
  end


  desc 'region_all'

  get 'region_all' do
    @region = Region.all
  end


  desc 'region_children'

  params do
    requires :region_id, type: String, desc: 'region_id'
  end
  get 'region_children' do
    @region = Region.find(params[:region_id])
    data_array = []
    @region.descendants.each do |r|
      data = {}
      data['region'] = r.name
      data['region_id'] = r.id
      data['chateau_count'] = eval r.descendants.map { |c| c.chateaus.count }.join('+')
      data_array << data
    end
    data_array
  end




  desc 'comment'

  params do
    requires :chateau_id, type: String, desc: 'chateau_id'
    requires :user_id, type: String, desc: 'user_id'
    requires :content, type: String, desc: 'content'
  end
  post 'comment' do
    @chateau = Chateau.find(params[:chateau_id])
    chateau_comment = ChateauComment.new
    chateau_comment.content = params[:content]
    @chateau.chateau_comments << chateau_comment
    if @chateau.save
      {:success => true}
    else
      {:success => false}
    end

  end

end