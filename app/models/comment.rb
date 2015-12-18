class Comment
  include Mongoid::Document
  include Mongoid::Timestamps

  after_create :set_product_state
  before_create :set_previous_state

  belongs_to :product
  belongs_to :user

  belongs_to :state
  belongs_to :previous_state, :class_name => "State"

  validates :content, :presence => true

  field :content, type: String


  private

  def set_previous_state
    self.previous_state = product.state
  end

  def set_product_state
    self.product.state = self.state
    self.product.save!
  end
end
