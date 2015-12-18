module Entities
  class FullReduction < Grape::Entity
    expose :groupName, documentation: {type: String, desc: '组名称'}
    expose :groupTag, documentation: {type: String, desc: '组标签'}
    expose :id, documentation: {type: String, desc: '活动id'}
    expose :name, documentation: {type: String, desc: '活动名称'}
    expose :aasm_state, documentation: {type: String, desc: '活动状态,noBeging: 未开始, beging: 正在进行, end: 已结束'}
    expose :startTime, documentation: {type: String, desc: '生效时间'}
    expose :endTime, documentation: {type: String, desc: '过期时间'}
    expose :quota, documentation: {type: Float, desc: '满额'}
    expose :reduction, documentation: {type: Float, desc: '减少的金额'}
    expose :integral, documentation: {type: String, desc: '赠送的积分'}
    expose :purchase_quantity, documentation: {type: String, desc: '购买数量'}
    expose :preferential_way, documentation: {type: Boolean, desc: '优惠方式，1.减现金，2.送积分，3.送优惠券, 4.买赠，5.送赠品'}
    expose :tag, documentation: {type: String, desc: '为商品同步打的标签'}
    expose :url, documentation: {type: String, desc: '活动h5页面地址'}
    expose :couponIds, documentation: {type: String, desc: '优惠券id列表', is_array: true}
    expose :gifts_product_ids, documentation: {type: String, desc: '赠品列表', is_array: true}
    expose :participate_product_ids, documentation: {type: String, desc: '参与活动的商品列表', is_array: true}
    expose :products, documentation: {type: String, desc: '购物车分组时用到的活动商品列表', is_array: true}
  end
end