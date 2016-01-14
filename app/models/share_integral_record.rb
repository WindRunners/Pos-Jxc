class ShareIntegralRecord
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  field :shared_customer_id, type: String
  field :register_customer_id, type: String
  field :is_confirm, type: Integer, default: 0


  belongs_to :share_integral


end
