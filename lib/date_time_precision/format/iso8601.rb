module DateTimePrecision
  ISO8601_DATE_FRAGMENTS = %w(%0*d %02d %02d)
  ISO8601_TIME_FRAGMENTS = %w(%02d %02d %02d)
end

[Date, Time, DateTime].each do |klass|
  klass.class_eval do
    if method_defined?(:xmlschema)
      alias_method :xmlschema_without_precision, :xmlschema
    end
    
    def xmlschema
      iso8601
    end

    if method_defined?(:iso8601)
      alias_method :iso8601_without_precision, :iso8601
    end
    def iso8601
      precision = self.precision || 0
      format = ""
      if precision > DateTimePrecision::NONE
        # Add date part to format
        format << DateTimePrecision::ISO8601_DATE_FRAGMENTS.take([3,self.precision].min).join('-')
      end

      if precision > DateTimePrecision::DAY
        format << "T#{DateTimePrecision::ISO8601_TIME_FRAGMENTS.take(precision - 3).join(':')}"
      end

      output = sprintf(format, year < 0 ? 5 : 4, *self.fragments)

      # Fractional seconds
      if sec_frac? && sec_frac > 0
        output << '.' + sprintf('%0*d', sec_frac, (subsec * 10**sec_frac).floor)
      end

      # Timezone
      if precision > DateTimePrecision::DAY
        if utc?
          output << 'Z'
        else
          off = utc_offset
          sign = off < 0 ? '-' : '+'
          output << sprintf('%s%02d:%02d', sign, *(off.abs / 60).divmod(60))
        end
      end
      
      output
    end
  end
end