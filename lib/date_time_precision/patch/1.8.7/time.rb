require 'date_time_precision/lib'
require 'time'

class Time
  include DateTimePrecision
  
  MAX_PRECISION = DateTimePrecision::SEC

  class << self
    alias_method :mktime_orig, :mktime
    def mktime(*args)
      time_args = args.shift(Time::MAX_PRECISION)
      precision = self.precision(time_args)
      time_args = normalize_new_args(time_args)
      
      t = mktime_orig(*[time_args, args].flatten)
      t.precision = precision
      t
    end
    
    alias_method :make_time_orig, :make_time
    def make_time(*args)
      time_args = args.shift(Time::MAX_PRECISION)
      precision = self.precision(time_args)
      time_args = normalize_new_args(time_args)
      
      t = make_time_orig(*[time_args, args].flatten)
      t.precision = precision
      t
    end
    private :make_time
  end

  #def self.strptime(str='-4712-01-01', fmt='%F', sg=Date::ITALY)
  #  DateTime.strptime(str, fmt, sg).to_time
  #end
end