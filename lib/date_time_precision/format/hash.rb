require 'date_time_precision/lib'

class Hash
  DATE_FORMATS = {
    :short => [:y, :m, :d],
    :long => [:year, :month, :day],
    :ruby => [:year, :mon, :mday, :hour, :min, :sec, :sec_frac]
  }
  DATE_FORMATS[:default] = DATE_FORMATS[:ruby]
  
  def to_time
    Time.mktime(*date_time_args)
  end
  
  def to_datetime
    DateTime.new(*date_time_args.take(DateTime::MAX_PRECISION))
  end
  
  def to_date
    Date.new(*date_time_args.take(Date::MAX_PRECISION))
  end
  
  protected
  def date_time_args
    [self[:year] || self[:y] || self[:yr] || self['year'] || self['y'] || self['yr'],
    self[:mon] || self[:m] || self[:month] || self['mon'] || self['m'] || self['month'],
    self[:mday] || self[:d] || self[:day] || self['mday'] || self['d'] || self['day'],
    self[:hour] || self[:h] || self[:hr] || self['hour'] || self['h'] || self['hr'],
    self[:min] || self['min'],
    self[:sec] || self[:s] || self['sec'] || self['s'],
    self[:sec_frac] || self['sec_frac']]
  end
end

module DateTimePrecision
  def to_h(format = nil)
    keys = Hash::DATE_FORMATS[format || :default]
    
    Hash[keys.each_with_index.map do |key,i|
      attribute_name = Hash::DATE_FORMATS[:ruby][i]
      [key, self.send(attribute_name)] if self.send("#{attribute_name}?")
    end.compact]
  end
end

require 'date_time_precision/compat/virtus' if defined?(Virtus)
require 'date_time_precision/compat/coercible' if defined?(Coercible)
