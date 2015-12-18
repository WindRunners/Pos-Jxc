module Entities
  class Userinfo < Grape::Entity
    expose :id, documentation: {type: String, desc: '小B的ID'}
    expose :pdistance, documentation: {type: Integer, desc: '小B的配送距离'}
    expose :shopname, documentation: {type: String, desc: '小B的商店名称'}
    expose :location, documentation: {type: Array, desc: '小B的经纬度'}
    expose :lowestprice, documentation: {type: Integer, desc: '小B的配送节点前起送金额'}
    expose :fright, documentation: {type: Integer, desc: '小B的配送节点前配送费'}
    expose :fright_time, documentation: {type: String, desc: '小B的配送时间节点'}
    expose :night_time, documentation: {type: String, desc: '小B的配送时间节点'}
    expose :start_business, documentation: {type: String, desc: '小B的开业时间'}
    expose :end_business, documentation: {type: String, desc: '小B的开业时间'}
    expose :h_lowestprice, documentation: {type: Integer, desc: '小B的配送节点后的最低配送金额'}
    expose :h_fright, documentation: {type: Integer, desc: '小B的配送节点后的配送费'}
    expose :work_24,documentation:{type:String,desc:'24小时店标示 true／false'}
  end
end
