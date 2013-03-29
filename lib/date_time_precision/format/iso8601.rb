[Date, Time, DateTime].each do |klass|
  klass.class_eval do
    ISO8601_DATE_FRAGMENTS = %w(%0*d %02d %02d)
    ISO8601_TIME_FRAGMENTS = %w(%02d %02d %02d)

    alias_method :xmlschema_without_precision, :xmlschema
    def xmlschema
      if self.precision
        iso8601
      else
        xmlschema_without_precision
      end
    end

    alias_method :iso8601_without_precision, :iso8601
    def iso8601
      if self.precision
        format = ""
        if self.precision > DateTimePrecision::NONE
          # Add date part to format
          format << ISO8601_DATE_FRAGMENTS.take([3,self.precision].min).join('-')
        end

        if self.precision > DateTimePrecision::DAY
          format << "T#{ISO8601_TIME_FRAGMENTS.take(self.precision - 3).join(':')}"
        end

        output = sprintf(format, year < 0 ? 5 : 4, *self.fragments)

        # Fractional seconds
        if sec_frac? && sec_frac > 0
          output << '.' + sprintf('%0*d', sec_frac, (subsec * 10**sec_frac).floor)
        end

        # Timezone
        if self.precision > DateTimePrecision::DAY
          if utc?
            output << 'Z'
          else
            off = utc_offset
            sign = off < 0 ? '-' : '+'
            output << sprintf('%s%02d:%02d', sign, *(off.abs / 60).divmod(60))
          end
        end
        
        output
      else
        iso8601_without_precision
      end
    end
  end
end