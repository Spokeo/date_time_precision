
class Hash
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
    [self[:year] || self[:y],
    self[:mon] || self[:m] || self[:month],
    self[:mday] || self[:d] || self[:day],
    self[:hour] || self[:h],
    self[:min],
    self[:sec],
    self[:sec_frac]]
  end
end