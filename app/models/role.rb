class Role
  include Mongoid::Document
  include Mongoid::Timestamps

  has_and_belongs_to_many :users
  belongs_to :resource, :polymorphic => true


  field :name, :type => String
  field :role_mark, :type => String ,default: 'business' #角色标识 business:运营商角色（对运营商），platform：平台角色（对平台）

  index({
            :name => 1,
            :resource_type => 1,
            :resource_id => 1
        },
        { :unique => true})

  validates :resource_type,
            :inclusion => { :in => Rolify.resource_types },
            :allow_nil => true

  validates :name, presence: true, uniqueness: true

  scopify
end