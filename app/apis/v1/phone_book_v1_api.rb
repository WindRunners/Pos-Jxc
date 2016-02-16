require 'grape'

class PhoneBookV1API < Grape::API
  format :json

  desc '所有分类'

  get 'all' do
    ["快递", "机票", "租车", "银行", "品牌售后", "公共服务", "证券", "酒店", "旅游", "代驾", "保险","医院"]
  end

end