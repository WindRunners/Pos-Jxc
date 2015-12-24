class OrderStateCount
  include Mongoid::Document

  field :order_all_count, type: Integer,default:0
  field :order_generation_count, type: Integer,default:0
  field :order_paid_count, type: Integer,default:0
  field :order_distribution_count, type: Integer,default:0
  field :order_receive_count, type: Integer,default:0

  def self.build_orderStateCount

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

    orderStateCount = OrderStateCount.new

    orders = Order.map_reduce(map, reduce).out(inline: true)

    begin
      orders.each do |state_count|

        statecount = state_count["value"]["count"].to_i

        if "generation" == state_count["_id"]
          orderStateCount.order_generation_count = statecount
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
        orderStateCount.order_all_count = Order.count + Ordercompleted.count
      end
    rescue

    end


    return orderStateCount
  end

end
