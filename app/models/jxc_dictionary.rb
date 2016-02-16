class JxcDictionary
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic

  field :dic, type: String #字典名称
  field :dic_desc, type: String #字典描述
  field :sort, type: Integer #排序码
  field :pinyin_code, type: String #拼音码

  validates :dic,:dic_desc,:pinyin_code, presence: true
end
