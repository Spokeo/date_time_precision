require 'date_time_precision/patch'

module DateTimePrecision
  def as_json(*)
    to_h
  end
  
  def to_json(*args)
    to_h.to_json(args)
  end
end