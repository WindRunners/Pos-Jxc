class UserinfoAsk
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip
  include Mongoid::Geospatial

  belongs_to :userinfo

  field :shopname, type: String
  field :approver, type: String
  field :pdistance_state, type: Integer,default: 0
  field :pdistance_ask, type: Integer,default: 0
  field :ask_date, type: DateTime
  field :rqe_date, type: DateTime

  field :location_data,type:String
  field :location, type: Point, spatial: true,default: []
  attr_accessor :lng, :lat

  def date_show
    if self.pdistance_state ==1
      p '申请中'
    elsif self.pdistance_state ==0
      p '成功'
    end
  end
end
