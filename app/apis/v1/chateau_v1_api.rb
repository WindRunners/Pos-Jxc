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
    chateau = Chateau.find(params[:chateau_id])
    data = {}
    # 酒庄基本属性
    data['chateau'] = chateau
    # 详细H5页面地址
    data['introduce'] = '/chateaus/'+chateau.id+'/introduce_show'
    # 标签
    mark_array = []
    chateau.chateau_marks.each do |m|
      mark_hash = {}
      mark_hash[m.name] = m.value
      mark_array << mark_hash
    end
    data['mark'] = mark_array
    # 轮播图地址数组
    pic_array = []
    chateau.pictures.limit(5).each do |p|
      pic_array << p.pic.url
    end
    data['pic'] = pic_array
    #酒庄拥有的酒款
    data['wines'] = chateau.wines
    data
  end


  desc 'chateau_list'do
    success Entities::Chateau
  end

  params do
    requires :region_id, type: String, desc: 'region_id'
    requires :page, type: String, desc: '当前页'
    requires :per_page, type: String, desc: '每页纪录数目'
  end

  get 'chateau_list' do

    region_id_array = []
    region = Region.find(params[:region_id])
    region_id_array << region['_id']
    region.descendants_and_self.each do |r|
      region_id_array << r['_id']
    end
    present Chateau.where({:status => 1, 'region_id' => {"$in" => region_id_array}}).page(params[:page]).per(params[:per_page]).order('created_at DESC'), with: Entities::Chateau
  end


  desc '产地一级目录'

  get 'region_root' do
    Region.root.children if Region.root.present?
  end


  desc '产地下级目录'

  params do
    requires :region_id, type: String, desc: 'region_id'
  end
  get 'region_children' do
    region = Region.find(params[:region_id])
    data_array = []
    region.descendants.each do |r|
      data = {}
      data['region'] = r.name
      data['region_id'] = r.id
      chateau_count = eval r.descendants.map { |c| c.chateaus.count }.join('+')
      if chateau_count.present?
        data['chateau_count'] = chateau_count
      else
        data['chateau_count'] =0
      end
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
    chateau = Chateau.find(params[:chateau_id])
    chateau_comment = ChateauComment.new
    chateau_comment.content = params[:content]
    chateau.chateau_comments << chateau_comment
    if chateau.save
      {:success => true}
    else
      {:success => false}
    end

  end

end