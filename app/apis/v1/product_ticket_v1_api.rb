require 'grape'

class ProductTicketV1API < Grape::API
  format :json



  desc '酒券列表'
  params do
    requires :customer_id, type: String, desc: '小c的ID'
  end
  get 'card_bag_list' do
    card_bags = CardBag.where(:customer_id=>params[:customer_id])
    binding.pry
    card_bag_list = []
    card_bags.each do |card_bag|
      card_bag_list<<card_bag.product_ticket
    end
    card_bag_list
  end



  desc '酒券详细'
  params do
    requires :product_ticket_id, type: String, desc: '酒券的ID'
    requires :customer_id, type: String, desc: '小c的ID'
  end
  get 'product_ticket_detail' do
    product_ticket = ProductTicket.where(:id=>params[:product_ticket_id]).first
    product_ticket['url']= "product_tickets/"+product_ticket.id+"/share?customer_id="+params[:customer_id]
    present product_ticket, with: Entities::ProductTicket
  end


end