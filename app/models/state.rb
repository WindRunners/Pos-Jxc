class State
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :value, type: String
  field :color, type: String
  field :background, type: String

  def to_s
    name
  end
  validates :name, presence: true, uniqueness: true

  def product_counts(user)
    Product.shop(user).where(state_id:id).count
  end
end
