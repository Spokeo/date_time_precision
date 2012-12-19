require 'date_time_precision/lib'
require 'date'

class DateTime < Date
  include DateTimePrecision

  MAX_PRECISION = DateTimePrecision::SEC

  class << self
    alias_method :new_orig, :new
    def new(*args)
      precision = self.precision(args)
      d = new_orig(*args)
      d.precision= precision
      d
    end
    
    alias_method :parse_orig, :parse
    def parse(str='-4712-01-01T00:00:00+00:00', now=self.now)
      comp = !block_given?
      elem = _parse(str, comp)
      precision = self.precision(elem)
      dt = parse_orig(str, now)
      dt.precision = precision
      dt
    end
    
    alias_method :civil_orig, :civil
    def civil(y=nil, m=nil, d=nil, sg=Date::ITALY)
      vals = [y,m,d]
      precision = self.precision(vals)
      unless vals.all?
        vals = vals.compact
        vals = vals.concat(NEW_DEFAULTS.slice(vals.length, NEW_DEFAULTS.length - vals.length))
      end
      y,m,d = vals
    
      dt = civil_orig(y,m,d,sg)
      dt.precision = precision
      dt
    end
    
    alias_method :strptime_orig, :strptime
    def strptime(date, format='%F', start=Date::ITALY)
      elem = _strptime(date, format)
      precision = self.precision(elem)
      d = strptime_orig(date, format, start)
      d.precision = precision
      d
    end
  end
  
end