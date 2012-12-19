module DateTimePrecision
  unless constants.include? "NONE"
    FRAC  = 7
    SEC   = 6
    MIN   = 5
    HOUR  = 4
    DAY   = 3
    MONTH = 2
    YEAR  = 1
    NONE  = 0
  
    # Default values for y,m,d,h,m,s,frac
    NEW_DEFAULTS = [-4712,1,1,0,0,0,0]
  end

  # Returns the precision for this Date/Time object, or the
  # maximum precision if none was specified
  def precision
    @precision = self.class::MAX_PRECISION unless @precision
    return @precision
  end

  def precision=(prec)
    @precision = [prec,self.class::MAX_PRECISION].min
  end

  def self.precision(val)
    case val
    when Date,Time,DateTime
      val.precision
    when Hash
      case
      when val[:sec_frac]
        FRAC
      when val[:sec]
        SEC
      when val[:min]
        MIN
      when val[:hour]
        HOUR
      when val[:mday]
        DAY
      when val[:mon]
        MONTH
      when val[:year]
        YEAR
      else
        NONE
      end
    when Array
      val.compact.length
    else
      NONE
    end
  end

  def subsec?
    return self.precision >= FRAC
  end

  def sec?
    return self.precision >= SEC
  end

  def min?
    return self.precision >= MIN
  end

  def hour?
    return self.precision >= HOUR
  end
  
  def year?
    return self.precision >= YEAR
  end

  def month?
    return self.precision >= MONTH
  end
  alias_method :mon?, :month?

  def day?
    return self.precision >= DAY
  end
  
  def fragments
    frags = []
    frags << self.year if self.year?
    frags << self.month if self.month?
    frags << self.day if self.day?
    frags << self.hour if self.hour?
    frags << self.min if self.min?
    frags << self.sec if self.sec?
    frags
  end
  
  # Returns true if dates partially match (i.e. one is a partial date of the other)
  def partial_match?(date2)
    self.class::partial_match?(self, date2)
  end
  
  module ClassMethods
    def partial_match?(date1, date2)
      return true if date1.nil? or date2.nil?
      frags1 = date1.fragments
      frags2 = date2.fragments
      min_precision = [frags1.length,frags2.length].min
      frags1.slice(0,min_precision) == frags2.slice(0,min_precision)
    end
    
    def precision(val)
      val = val.take(self::MAX_PRECISION) if val.is_a? Array
      DateTimePrecision::precision(val)
    end
  end

  def self.included(base)
    # Redefine any conversion methods so precision is preserved
    [:to_date, :to_time, :to_datetime].each do |m|
      orig = :"orig_#{m}"
      if base.method_defined?(m) && !base.method_defined?(orig)
        base.class_exec {
          alias_method orig, m
          define_method(m) {
            d = send(orig)
            d.precision = [self.precision, d.class::MAX_PRECISION].min
            d
          }
        }
      end
    end
    
    # Extend with this module's class methods
    base.extend(ClassMethods)
  end
end