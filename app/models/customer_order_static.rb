class CustomerOrderStatic
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic

  field :customer_id, type: String #小Cid
  field :mobile, type: String #手机号
  field :quantity, type: Integer #数量
  field :userinfo_ids, type: Array #小Bid集合
  field :order_ids, type: Array #汇总过的订单id集合


  def completed_order_successful(order_id)

    order = Ordercompleted.find(order_id)
    begin

      return if order['customer_id'].present? #订单可能是线下订单与会员无关

      isorder_count = CustomerOrderStatic.where(:customer_id => order['customer_id'],order_ids: order_id).count() #检测当期订单是否已统计
      return if isorder_count > 0

      customer = Customer.find(order['customer_id'])
      customerOrderStatic = CustomerOrderStatic.where(:customer_id => customer.id).find_or_create_by({:customer_id => customer.id,:mobile => customer.mobile})
      # customerOrderStatic = CustomerOrderStatic.find_or_create_by(:customer_id => customer.id)
      userinfo_id = order['userinfo_id'].to_s

      order_date =  order.created_at.strftime("%Y.%m.%d")
      customerOrderStatic.inc("#{order_date}.#{userinfo_id}" => 1) #增加订单量
      customerOrderStatic.add_to_set({:userinfo_ids => userinfo_id,:order_ids => order_id}) #增加小Bid
    rescue Exception => e #异常捕获
      puts e.message
      Rails.logger.info "订单#{order.orderno} 会员订单统计失败！！！"
    end

  end

end