
class Hash
  def to_time
    Time.mktime(self[:year], self[:mon], self[:mday], self[:hour], self[:min], self[:sec], self[:sec_frac])
  end
  
  def to_datetime
    DateTime.new(self[:year], self[:mon], self[:mday], self[:hour], self[:min], self[:sec])
  end
  
  def to_date
    Date.new(self[:year], self[:mon], self[:mday])
  end
end