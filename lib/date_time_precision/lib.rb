if defined?(ActiveSupport)
  ['active_support/core_ext/date', 'active_support/core_ext/datetime', 'active_support/core_ext/time', 'active_support/time'].each do |f|
    begin
      require f
    rescue LoadError; end
  end
end

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
    
    DATE_ATTRIBUTES = {
      :year => YEAR,
      :mon => MONTH,
      :mday => DAY,
      :hour => HOUR,
      :min => MIN,
      :sec => SEC,
      :sec_frac => FRAC
    }
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
      when val[:sec_frac], val[:subsec]
        FRAC
      when val[:sec]
        SEC
      when val[:min]
        MIN
      when val[:hour]
        HOUR
      when val[:mday], val[:day]
        DAY
      when val[:mon], val[:month]
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

  # Define attribute query methods
  DATE_ATTRIBUTES.each do |attribute_name, precision|
    define_method "#{attribute_name}?" do
      return self.precision >= precision
    end
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
  
  def normalize_new_args(args)
    self.class.normalize_new_args(args)
  end
  protected :normalize_new_args
  
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
    
    def normalize_new_args(args)
      unless args.all?
        args = args.compact
        args = args.concat(DateTimePrecision::NEW_DEFAULTS.slice(args.length, DateTimePrecision::NEW_DEFAULTS.length - args.length))
      end
      args.take(self::MAX_PRECISION)
    end
  end

  def self.included(base)
    # Redefine any conversion methods so precision is preserved
    [:to_date, :to_time, :to_datetime].each do |conversion_method|
      orig = :"orig_#{conversion_method}"
      if base.method_defined?(conversion_method) && !base.instance_methods(false).map(&:to_sym).include?(orig)
        base.class_exec {
          alias_method orig, conversion_method
          define_method(conversion_method) {
            d = send(orig)
            d.precision = [self.precision, d.class::MAX_PRECISION].min
            d
          }
        }
      end
    end
    
    # Extend with this module's class methods
    base.extend(ClassMethods)
    
    base.instance_eval do
      if method_defined?(:usec)
        alias_method :usec?, :sec_frac?
        alias_method :sec_frac, :usec
      end
      
      if method_defined?(:subsec)
        alias_method :subsec?, :sec_frac?
      end

      alias_method :month?, :mon?

      alias_method :mday, :day
      alias_method :day?, :mday?
    end
  end
end