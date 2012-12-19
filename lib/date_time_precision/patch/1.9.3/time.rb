require 'date_time_precision/lib'
require 'time'

class Time
  include DateTimePrecision
  
  MAX_PRECISION = DateTimePrecision::FRAC

  class << self
    alias_method :make_time_orig, :make_time
    def make_time(*args)
      t = make_time_orig(*args)
      t.precision = self.precision(args)
      t
    end
    private :make_time
  end
end