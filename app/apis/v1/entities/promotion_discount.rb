module Entities
  class PromotionDiscount < Grape::Entity
    expose :id, documentation: {type: String, desc: '促销打折id'}
    expose :title, documentation: {type: String, desc: '促销打折标题'}
    expose :discount, documentation: {type: Integer, desc: '折扣'}
    expose :type, documentation: {type: String, desc: '活动类型0:打折，1:促销'}
    expose :startTimeShow, documentation: {type: String, desc: '开始时间'}, as: "start_time"
    expose :endTimeShow, documentation: {type: String, desc: '结束时间'}, as: "end_time"
    expose :aasm_state, documentation: {type: String, desc: '活动状态,noBeging:未开始, beging:正在进行, end:已结束'}
    expose :tag, documentation: {type: String, desc: '为商品打的标签'}
    expose :avatar, documentation: {type: String, desc: "活动图片url"}
  end
end
