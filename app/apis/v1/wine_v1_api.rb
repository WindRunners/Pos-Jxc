require 'grape'

class WineV1API < Grape::API
  format :json

  desc '所有' do
    success Entities::Wine
  end

  get 'all' do
    present Wine.all, with: Entities::Wine
  end


  desc '列表' do
    success Entities::Wine
  end
  params do
    requires :condition, type: String, desc: '搜索条件'
    requires :page, type: String, desc: '当前页'
    requires :per_page, type: String, desc: '每页纪录数目'
  end

  get 'list' do
    present Wine.where(params[:condition]).page(params[:page]).per(params[:per_page]), with: Entities::Wine
  end

  desc '详细'
  params do
    requires :wine_id, type: String, desc: 'wine_id'
  end

  get 'show' do
    @wine = Wine.find(params[:wine_id])
    data = {}
    data['wine'] = @wine
    data['introduce'] = @wine.chateau_introduce.introduce if @wine.chateau_introduce.present?
    data['mark'] = @wine.chateau_marks
    pic_array = []
    @wine.pictures.each do |p|
      pic_array << p.pic.url
    end
    data['pictures'] = pic_array
    data
  end


end