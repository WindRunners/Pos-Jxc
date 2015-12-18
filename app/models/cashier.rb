class Cashier
  include Mongoid::Document
  field :totalPrice, type: Float
  field :discount, type: String
end
