require 'active_support/core_ext/date/conversions'

Date::DATE_FORMATS[:long] = lambda do |date|
  case
    when date.precision.nil?, date.precision >= DateTimePrecision::DAY
      date.strftime("%B %e, %Y")
    when date.precision == DateTimePrecision::MONTH
      date.strftime("%B %Y")
    when date.precision == DateTimePrecision::YEAR
      date.strftime("%Y")
    else
      ""
    end
end

Time::DATE_FORMATS[:long] = lambda do |time|
  case
    when time.precision.nil?, time.precision >= DateTimePrecision::MIN
      time.strftime("%B %d, %Y %H:%M")
    #when time.precision == DateTimePrecision::HOUR
    #  time.strftime("%B %d, %Y %H")
    when time.precision >= DateTimePrecision::DAY
      time.strftime("%B %d, %Y")
    when time.precision == DateTimePrecision::MONTH
      time.strftime("%B %Y")
    when time.precision == DateTimePrecision::YEAR
      time.strftime("%Y")
    else
      ""
    end
end
