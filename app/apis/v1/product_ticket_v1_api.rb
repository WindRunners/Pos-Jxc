require 'grape'

class ProductTicketV1API < Grape::API
  format :json



  desc '酒券列表'
  params do
    requires :customer_id, type: String, desc: '小c的ID'
  end
  get 'card_list' do


  end

  desc '酒券详细'
  params do
    requires :product_ticket_id, type: String, desc: '酒券的ID'
  end
  get 'card_detail' do


  end


end