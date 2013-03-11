require 'spec_helper'
require 'json'
require 'securerandom'
require 'active_support'

require 'date_time_precision'

require 'date_time_precision/format/json'

describe DateTimePrecision, 'Conversions' do  
  context 'when converting from Date to Time or DateTime' do
    it 'should maintain precision' do
      d = Date.new(2005, 1)
      d.precision.should == DateTimePrecision::MONTH
      d.to_date.precision.should == DateTimePrecision::MONTH
      d.to_datetime.precision.should == DateTimePrecision::MONTH
    end
  end
  
  it 'will lose precision when converting from DateTime or Time to Date' do
    t = Time::parse('2000-1-1 00:00:00 EST') # => Fri Dec 31 21:00:00 -0800 1999
    t.precision.should == DateTimePrecision::SEC
    t.to_datetime.precision.should == DateTime::MAX_PRECISION
    t.to_date.precision.should == DateTimePrecision::DAY
  end
  
  it 'will convert a date to a hash' do
    date = Date.new(1999, 10)
    date.as_json.should == date.to_h
  end
  
  it 'will retain precision when converting to and from JSON' do
    date = Date.new(1999, 10)
    date.precision.should == DateTimePrecision::MONTH
    json = ActiveSupport::JSON.encode(date)
    
    date_from_json = ActiveSupport::JSON.decode(json).to_date
    date_from_json.precision.should == date.precision
    
  end
end