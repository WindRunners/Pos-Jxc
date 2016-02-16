class OrderJsonBack
  include Mongoid::Document

  field :state,type:Integer
  field :products,type:Array,default: []
  field :fullReductions,type:Array,default: []
  field :coupon_id
  field :use_coupon,type: Boolean,default: true
  field :order,type:Order
  field :activities,type:Array,default: []



  #校验除了普通商品以外的活动是否已经结束
  def activitie_check(activities)
    activities.each do |activitie|
      if 0 != activitie['preferential_way']
        self.use_coupon = false      #参加活动不使用优惠券
        begin
          fullReduction = FullReduction.find_by(:id => activitie['activitie_id'],
                                                :preferential_way => activitie['preferential_way'],
                                                :aasm_state => :beging)

          fullReduction.ordergoods.concat(activitie['ordergoods'])
          self.activities << fullReduction
        rescue
          self.fullReductions << {"fullReduction_id" => activitie['activitie_id']}
          next
        end
      else
        fullReduction = FullReduction.new(:preferential_way => "0")
        fullReduction.ordergoods.concat(activitie['ordergoods'])
        self.activities << fullReduction
      end
    end

    self.state = 602 if self.fullReductions.size > 0

    return self
  end


  #校验库存
  def stock_check(userinfo_id,build_order)
    self.activities.each do |activitie|
      goodArray = []
      activitie.ordergoods.each do |ordergood|
        good = Ordergood.new(ordergood)

        begin
          product = Product.shop_id(userinfo_id).find(ordergood['product_id'])
          if product.panic_price != 0
            self.use_coupon = false    #参加活动不使用优惠券

            if !product.panic_buying.nil?
              if product.panic_quantity < good.quantity
                self.products << {"id" => product.id,"stock" => product.panic_quantity}
                next
              else
                good.price = product.panic_price
              end
            else
              if product.stock < good.quantity
                self.products << {"id" => product.id,"stock" => product.stock}
                next
              else
                good.price = product.price
              end
            end
          else
            if product.stock < good.quantity
              self.products << {"id" => product.id,"stock" => product.stock}
              next
            else
              good.price = product.price
            end
          end
          if build_order
            good.purchasePrice = product.purchasePrice
            good.integral = product.integral
            good.qrcode = product.qrcode
            good.avatar = product.avatar
            good.specification = product.specification
          end
          good.title = product.title
          goodArray << good
        end
      end
      activitie.ordergoods = goodArray

    end

    self.state = 601 if self.products.size > 0

    return self
  end
end