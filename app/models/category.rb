class Category
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic

  belongs_to :parent, :class_name => "Category",:foreign_key => :parent_id

  has_many :childs, :class_name => "Category"

  has_and_belongs_to_many :products

  field :title
  field :form
  field :desc
  field :field

  validates :title, presence: true, uniqueness: true

  #validates :form, uniqueness: true

  def text
    title
  end

  def type
    if childs.count > 0
      'folder'
    else
      'item'
    end

  end

  def isLeaf?
    childs.count == 0
  end

  def additionalParameters
    array = []

    ids = {}
    ids[:id] = id
    ids[:children] = childs.count > 0

    array << ids
  end

  def detail
    array = []

    item = self

    while not item.parent.blank? do
      array << item.title
      item = item.parent
    end

    array.reverse
  end

  # def as_json(options={})
  #   super(:include => [:text, :type, :additionalParameters])
  # end
end
