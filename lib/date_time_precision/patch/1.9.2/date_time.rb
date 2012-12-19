require 'date_time_precision/lib'
require 'date'

class DateTime < Date
  include DateTimePrecision

  MAX_PRECISION = DateTimePrecision::SEC

  def self.parse(str='-4712-01-01T00:00:00+00:00', comp=false, sg=ITALY)
    elem = _parse(str, comp)
    precision = DateTimePrecision::precision(elem)
    dt = new_by_frags(elem, sg)
    dt.precision = precision
    dt
  end

  def self.civil(y=nil, m=nil, d=nil, h=nil, min=nil, s=nil, of=0, sg=ITALY)
    vals = [y,m,d,h,min,s]
    precision = DateTimePrecision::precision(vals)
    unless vals.all?
      vals = vals.compact
      vals = vals.concat(NEW_DEFAULTS.slice(vals.length, NEW_DEFAULTS.length - vals.length))
    end
    y,m,d,h,min,s = vals
  
    unless (jd = _valid_civil?(y, m, d, sg)) && (fr = _valid_time?(h, min, s))
      raise ArgumentError, 'invalid date'
    end
    if String === of
      of = Rational(zone_to_diff(of) || 0, 86400)
    end
    dt = new!(jd_to_ajd(jd, fr, of), of, sg)
    dt.precision = precision
    dt
  end

  class << self; alias_method :new, :civil end

  def self.strptime(str='-4712-01-01', fmt='%F', sg=ITALY)
    elem = _strptime(str, fmt)
    precision = DateTimePrecision::precision(elem)
    d = new_by_frags(elem, sg)
    d.precision = precision
    d
  end
end