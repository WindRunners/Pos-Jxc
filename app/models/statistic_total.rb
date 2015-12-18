class StatisticTotal
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :product_id, type: String #商品id
  field :userinfo_id, type: String #小Bid
  field :total_quantity, type: Integer, default: 0#总销量
  field :total_income, type: Float, default: 0 #总收入
  field :total_order_number, type: Integer, default: 0 #总单量
  field :total_profit, type: Float, default: 0 #总利润

  def completed_order_successful(order_id)
    order = Ordercompleted.find(order_id)
    order.ordergoodcompleteds.each do |op|
      statisticTotal = StatisticTotal.find_or_create_by(:userinfo_id => order.userinfo.id.to_s, :product_id => op.product_id)
      statisticTotal.total_quantity += op.quantity
      statisticTotal.total_income += op.quantity * op.price
      statisticTotal.total_order_number += 1
      statisticTotal.total_profit += op.quantity * (op.price - op.purchasePrice)
      statisticTotal.save
    end
  end

  def after_product_save(product_id, userinfo_id)
    StatisticTotal.create(:userinfo_id => userinfo_id, :product_id => product_id)
  end
end
