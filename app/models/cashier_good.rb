class CashierGood
  include Mongoid::Document
  field :price, type: Float
  field :quantity, type: Integer
end
