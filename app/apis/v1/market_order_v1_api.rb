require 'grape'

class MarketOrderV1API < Grape::API
  format :json


  desc '小B接单' do
    success Entities::Ordercompleted
  end
  params do
    requires :orderid, type: String, desc: '订单id字符串'
  end
  post 'receive_order' do
    order = Order.find(params[:orderid])

    if order.receive_order!
      present order,with: Entities::Order
    else
      order.errors
    end
  end

  desc '小B配送完成' do
    success Entities::Ordercompleted
  end
  params do
    requires :orderid, type: String, desc: '订单id字符串'
  end
  post 'receive_goods' do
    order = Order.find(params[:orderid])
    if order.receive_goods!
      present order,with: Entities::Order
    else
      order.errors
    end
  end



  desc '小B查询待接单（paid）订单' do
    success Entities::Order
  end
  params do
    requires :userinfo_id,type: String, desc: '小B的id'
  end
  get 'search_orders_paid' do
    userinfo = Userinfo.find(params[:userinfo_id])
    orders = Rails.cache.fetch([self, 'search_orders_paid']) do
      Order.where(:userinfo => userinfo, :workflow_state => :paid).sort{|a, b| b["created_at"] <=> a["created_at"]}
    end
    present orders, with: Entities::Order
  end



  desc '查询小B配送中（distribution）的订单' do
    success Entities::Order
  end
  params do
    requires :userinfo_id,type: String, desc: '小B的id'
  end
  get 'search_orders_distribution' do
    userinfo = Userinfo.find(params[:userinfo_id])
    orders = Rails.cache.fetch([self, 'search_orders_distribution']) do
      Order.where(:userinfo => userinfo, :workflow_state => :distribution).sort{|a, b| b["created_at"] <=> a["created_at"]}
    end
    present orders, with: Entities::Order
  end


  desc '小B查询已完成（completed）订单' do
    success Entities::Ordercompleted
  end
  params do
    requires :userinfo_id,type: String, desc: '小B的id'
  end
  get 'search_orders_completed' do
    userinfo = Userinfo.find(params[:userinfo_id])
    ordercompleteds = Rails.cache.fetch([self, 'search_orders_completed']) do
      Ordercompleted.where(:userinfo => userinfo,  :workflow_state => :completed).sort{|a, b| b["created_at"] <=> a["created_at"]}
    end
    present ordercompleteds, with: Entities::Ordercompleted
  end


end