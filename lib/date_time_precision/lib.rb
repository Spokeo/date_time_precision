if defined?(ActiveSupport)
  ['active_support/core_ext/date', 'active_support/core_ext/datetime', 'active_support/core_ext/time', 'active_support/time', 'active_support/time_with_zone'].each do |f|
    begin
      require f
    rescue LoadError; end
  end
end

class Date
  unless method_defined?(:utc?)
    def utc?
      offset == 0
    end
  end
  
  unless method_defined?(:utc_offset)
    def utc_offset
      offset.numerator*3600
    end
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
    
    DATE_ATTRIBUTES = [
      :year,
      :mon,
      :day,
      :hour,
      :min,
      :sec,
      :sec_frac
    ]
    
    DATE_ATTRIBUTE_PRECISIONS = {
      :year => YEAR,
      :mon => MONTH,
      :day => DAY,
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
      when val[:mday], val[:day], val[:d]
        DAY
      when val[:mon], val[:month], val[:m]
        MONTH
      when val[:year], val[:y]
        YEAR
      else
        NONE
      end
    when Array
      val.index{|v| v.nil?} || val.length
    else
      NONE
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
        # Replace nil values with their corresponding default values
        args = args.each_with_index.map do |val,i|
          val || DateTimePrecision::NEW_DEFAULTS[i]
        end
      end
      args.take(self::MAX_PRECISION)
    end
  end

  def self.included(base)
    # Redefine any conversion methods so precision is preserved
    [:to_date, :to_time, :to_datetime].each do |conversion_method|
      # If the conversion method is already defined, patch it
      orig = :"orig_#{conversion_method}"
      if base.method_defined?(conversion_method) && !base.instance_methods(false).map(&:to_sym).include?(orig)
        base.class_eval do
          alias_method orig, conversion_method
          define_method(conversion_method) do
            d = send(orig)
            d.precision = [self.precision, d.class::MAX_PRECISION].min
            DATE_ATTRIBUTES.each do |attribute|
              d.instance_variable_set(:"@#{attribute}_set", self.instance_variable_get(:"@#{attribute}_set"))
            end
            d
          end
        end
      else
        # Define our own conversion methods by converting to hash first
        require 'date_time_precision/format/hash'
        base.class_eval do
          define_method(conversion_method) do
            to_h.send(conversion_method)
          end
        end
      end

      base.send :public, conversion_method
    end
    
    # Extend with this module's class methods
    base.extend(ClassMethods)
    
    # Define attribute query methods, including:
    # year?, mon?, day?, hour?, min?, sec?, sec_frac?
    DATE_ATTRIBUTE_PRECISIONS.each do |attribute_name, precision|
      #next unless precision <= base::MAX_PRECISION
      
      base.class_eval <<-EOM, __FILE__, __LINE__
        def #{attribute_name}?
          return !@#{attribute_name}_set.nil? ? @#{attribute_name}_set : (self.precision >= #{precision})
        end

        def #{attribute_name}_set=(val)
          @#{attribute_name}_set = !!val
        end
        protected :#{attribute_name}_set=
      EOM
    end
    
    base.class_eval <<-EOM, __FILE__, __LINE__
      def attributes_set(*vals)
        #{DATE_ATTRIBUTES.map{|attribute| "@#{attribute}_set"}.join(', ')} = *(vals.flatten.map{|v| !!v})
      end
    EOM
    
    base.class_eval do
      if method_defined?(:usec)
        alias_method :usec?, :sec_frac?
        alias_method :sec_frac, :usec
      end
      
      if method_defined?(:subsec)
        alias_method :subsec?, :sec_frac?
      end

      alias_method :month?, :mon?

      alias_method :mday, :day
      alias_method :mday?, :day?
    end
  end
end