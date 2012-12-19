require 'date_time_precision/lib'
require 'date'

class Date
  include DateTimePrecision

  MAX_PRECISION = DateTimePrecision::DAY

  def self.parse(str='-4712-01-01T00:00:00+00:00', comp=false, sg=ITALY)
    elem = _parse(str, comp)
    precision = DateTimePrecision::precision(elem)
    d = new_by_frags(elem, sg)
    d.precision = precision
    d
  end

  def self.strptime(str='-4712-01-01', fmt='%F', sg=ITALY)
    elem = _strptime(str, fmt)
    precision = DateTimePrecision::precision(elem)
    d = new_by_frags(elem, sg)
    d.precision = precision
    d
  end

  def self.civil(y=nil, m=nil, d=nil, sg=ITALY)
    vals = [y,m,d]
    precision = DateTimePrecision::precision(vals)
    unless vals.all?
      vals = vals.compact
      vals = vals.concat(NEW_DEFAULTS.slice(vals.length, NEW_DEFAULTS.length - vals.length))
    end
    y,m,d = vals
  
    unless jd = _valid_civil?(y, m, d, sg)
      raise ArgumentError, 'invalid date'
    end
  
    d = new!(jd_to_ajd(jd, 0, 0), 0, sg)
    d.precision = precision
    d
  end

  class << self; alias_method :new, :civil end

=begin
Following code is unneccessary, but keeping it as an example
  # Return the date as a human-readable string.
  #
  # The format used is YYYY-MM-DD, YYYY-MM, or YYYY.
  def to_s
    case 
    when self.precision.nil?, self.precision >= DateTimePrecision::DAY
      format('%.4d-%02d-%02d', year, mon, mday)
    when self.precision == DateTimePrecision::MONTH
      format('%.4d-%02d', year, mon)
    when self.precision == DateTimePrecision::YEAR
      format('%.4d', year)
    else
      '?'
    end
  end
=end

end