require 'date_time_precision/lib'
require 'time'

class Time
  include DateTimePrecision
  
  MAX_PRECISION = DateTimePrecision::SEC

  def self.parse(date, now=self.now)
    d = Date._parse(date, false)
    year = d[:year]
    year = yield(year) if year && block_given?
    t = make_time(year, d[:mon], d[:mday], d[:hour], d[:min], d[:sec], d[:sec_fraction], d[:zone], now)
    t.precision = DateTimePrecision::precision(d)
    t
  end

  #def self.strptime(str='-4712-01-01', fmt='%F', sg=Date::ITALY)
  #  DateTime.strptime(str, fmt, sg).to_time
  #end
end