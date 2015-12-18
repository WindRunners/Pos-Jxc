class Statistic
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :userinfo_id, type: String #小B的id
  field :order_id, type: String #订单ID
  field :product_id, type: String #商品id
  field :qrcode, type: String  #条形码
  field :productName, type: String  #商品名称
  field :purchasePrice, type: Float #进价
  field :retailPrice, type: Float  #成交价
  field :quantity, type: Integer  #数量
  field :cost_price, type: Float #成本价
  field :total_price, type: Float #成交总价
  field :profit, type: Float #利润
  field :retailDate, type: String #出售日期 格式:2015-11-25

    def completed_order_successful(order_id)
      order = Ordercompleted.find(order_id)
      order.ordergoodcompleteds.each do |op|
          statistic = Statistic.new(:userinfo_id => order.userinfo.id.to_s, :order_id => order_id, :product_id => op.product_id,
                                    :qrcode => op.qrcode, :productName => op.title, :purchasePrice => op.purchasePrice,
                                    :retailPrice => op.price, :quantity => op.quantity, :cost_price => op.purchasePrice * op.quantity,
                                    :total_price => op.quantity * op.price, :profit => op.quantity * (op.price - op.purchasePrice),
                                    :retailDate => op.created_at.strftime("%Y-%m-%d"))
          statistic.save
      end
    end
end
