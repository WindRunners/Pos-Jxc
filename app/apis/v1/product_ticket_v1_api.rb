require 'grape'

class ProductTicketV1API < Grape::API
  format :json

  desc '酒券列表'
  params do
    requires :customer_id, type: String, desc: '小c的ID'
  end
  get 'card_bag_list' do
    card_bags = CardBag.where(:customer_id => params[:customer_id])
    card_bag_list = []
    card_bags.each do |card_bag|
      product_ticket = card_bag.product_ticket
      product = Product.shop_id(product_ticket.userinfo_id).find(card_bag.product_ticket.product_id)
      product_ticket['product_id'] = product.id
      product_ticket['product_title'] = product.title
      product_ticket['product_avatar_url'] = product.avatar_url
      product_ticket['product_price'] = product.price
      card_bag_list << product_ticket
    end
    present card_bag_list, with: Entities::CardBagList
  end


  desc '酒券详细' do
    success Entities::ProductTicket
  end
  params do
    requires :product_ticket_id, type: String, desc: '酒券的ID'
    requires :customer_id, type: String, desc: '小c的ID'
  end
  get 'product_ticket_detail' do
    product_ticket = ProductTicket.where(:id => params[:product_ticket_id]).first
    product = Product.shop_id(product_ticket.userinfo_id).find(product_ticket.product_id)
    product_ticket['product_id'] = product.id
    product_ticket['product_title'] = product.title
    product_ticket['product_avatar_url'] = product.avatar_url
    product_ticket['product_price'] = product.price
    product_ticket['url']= "product_tickets/"+product_ticket.id+"/share?customer_id="+params[:customer_id]
    present product_ticket, with: Entities::ProductTicket
  end


end