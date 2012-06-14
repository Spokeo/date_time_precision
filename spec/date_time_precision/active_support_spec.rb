require 'spec_helper'
require 'active_support'
require 'date_time_precision'

describe DateTimePrecision, 'Conversions' do  
  context 'when converting from Date to Time or DateTime' do
    it 'should maintain precision' do
      d = Date.new(2005, 1, 2)
      d.precision.should == DateTimePrecision::DAY
      d.to_date.precision.should == DateTimePrecision::DAY
      d.to_datetime.precision.should == DateTimePrecision::DAY
    end
  end
  
  it 'will lose precision when converting from DateTime or Time to Date' do
    t = Time::parse('2000-1-1 00:00:00 EST') # => Fri Dec 31 21:00:00 -0800 1999
    t.precision.should == DateTimePrecision::SEC
    t.to_datetime.precision.should == DateTimePrecision::SEC
    t.to_date.precision.should == DateTimePrecision::DAY
  end
end