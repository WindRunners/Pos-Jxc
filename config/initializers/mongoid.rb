module BSON
  class ObjectId
    def to_json(*args)
      to_s.to_json
    end

    def as_json(*args)
      to_s.as_json
    end
  end
end

module ActiveSupport
  class TimeWithZone
    def to_short
      self.strftime("%Y-%m-%d %H:%M")
    end

    def to_s
      self.strftime("%Y-%m-%d %H:%M:%S")
    end
  end
end
