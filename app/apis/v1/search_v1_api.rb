require 'grape'

class SearchV1API < Grape::API

  format :json

  helpers do
    def ahoy
      @ahoy ||= Ahoy::Tracker.new
    end
  end

  use ApiLogger


  desc '随机生成10个热门搜索词'
  params do
    requires :id, type: String, desc: '小B的ID'
  end
  get :generate_keywords do
    Search.where(user_id:params[:id]).delete_all()

    keywords = ['茅台','五粮液','泸州老窖','二锅头','黑啤','长城干红','张裕','百威','黄酒','汇源', '轩尼诗']

    for keyword in keywords
      search = Search.new
      search.keyword = keyword
      search.hit = Faker::Number.between(1, 100)
      search.user_id = params[:id]
      search.save
    end

    {success:'ok'}
  end

  desc '获取小B的热门搜索词'
  params do
    requires :id, type: String, desc: '小B的ID'
  end
  get :hot_keywords do
    keywords = Search.where(user_id:params[:id]).limit(10).order_by(:hit => :desc).collect(&:keyword)
    keywords.join(",")
  end

  desc '搜索小B的商品列表' do
    success Entities::Product
  end
  params do
    requires :id, type: String, desc: '小B的ID'
    requires :keyword, type: String, desc: '关键词'
  end
  get 'search' do

    search = Search.find_or_create_by(keyword:params[:keyword])
    search.hit += 1
    search.save

    products = Product.shop_id(params[:id]).where({:title => /#{params[:keyword]}/})

    present products, with: Entities::Product
  end

  desc '搜索小B的关键字'
  params do
    requires :id, type: String, desc: '小B的ID'
    requires :keyword, type: String, desc: '关键词'
  end
  get 'keyword' do
    keyword = params[:keyword].downcase

    userinfo = Userinfo.find(params[:id])
    keywords = userinfo.keywords.or({:word => /#{keyword}/}).or({:pinyin => /#{keyword}/}).or({:py => /#{keyword}/})
    keywords.map(&:word).join(",")
  end
end