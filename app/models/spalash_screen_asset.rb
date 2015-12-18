class SpalashScreenAsset
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip

  field :img_path,type: String
  field :seconds,type: String
  field :stop_seconds, type: Integer
  field :start_time, type: DateTime
  field :end_time, type: DateTime

end
