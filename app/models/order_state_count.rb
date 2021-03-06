class OrderStateCount
  include Mongoid::Document

  field :order_all_count, type: Integer,default:0
  field :order_generation_count, type: Integer,default:0
  field :order_paid_count, type: Integer,default:0
  field :order_distribution_count, type: Integer,default:0
  field :order_receive_count, type: Integer,default:0


  #需要修改
  def self.build_orderStateCount(current_user)

    userinfo_id = current_user['userinfo_id'] #小Bid
    store_ids = current_user['store_ids'].present? ? current_user['store_ids'] : [] #负责门店列表


    map = %Q{
      function() {
        emit(this.workflow_state, { count: 1});
      }
    }

    reduce = %Q{
      function(key, values) {
        var count = 0;
        values.forEach(function(value) {
          count += value.count;
        });
        return {count : count};
      }
    }

    orderStateCount = OrderStateCount.new()

    curren_user_orders = Order.where(:userinfo_id => userinfo_id,:store_id => {"$in" => store_ids},:ordertype => 1)
    orders = curren_user_orders.map_reduce(map, reduce).out(inline: true)

    begin
      orders.each do |state_count|

        statecount = state_count["value"]["count"].to_i

        if "generation" == state_count["_id"]
          # orderStateCount.order_generation_count = Order.where(:userinfo_id => userinfo_id,:workflow_state=>'generation').count
        end

        if "paid" == state_count["_id"]
          orderStateCount.order_paid_count = statecount
        end

        if "distribution" == state_count["_id"]
          orderStateCount.order_distribution_count = statecount
        end

        if "receive" == state_count["_id"]
          orderStateCount.order_receive_count = statecount
        end
        # orderStateCount.order_all_count = curren_user_orders.count + Ordercompleted.where(:userinfo_id => userinfo_id,:store_id => {"$in" => store_ids}).count
      end

      orderStateCount.order_generation_count = Order.where(:userinfo_id => userinfo_id,:workflow_state=>'generation').count
    rescue

    end

    return orderStateCount
  end

end
