require 'spec_helper'
require 'json'
require 'securerandom'
require 'active_support'

require 'date_time_precision'

require 'date_time_precision/format/json'

describe DateTimePrecision, 'Conversions' do  
  context 'when converting from Date to Time or DateTime' do
    it 'maintains precision' do
      d = Date.new(2005, 1)
      d.precision.should == DateTimePrecision::MONTH
      d.to_date.precision.should == DateTimePrecision::MONTH
      d.to_datetime.precision.should == DateTimePrecision::MONTH
    end
  end
  
  it 'loses precision when converting from DateTime or Time to Date' do
    t = Time::parse('2000-1-1 00:00:00 EST') # => Fri Dec 31 21:00:00 -0800 1999
    t.precision.should == DateTimePrecision::SEC
    t.to_datetime.precision.should == DateTime::MAX_PRECISION
    t.to_date.precision.should == DateTimePrecision::DAY
  end
  
  it 'converts a date to a hash' do
    date = Date.new(1999, 10)
    date.as_json.should == date.to_h
  end
  
  it 'retains precision when converting to and from JSON' do
    date = Date.new(1999, 10)
    date.precision.should == DateTimePrecision::MONTH
    json = ActiveSupport::JSON.encode(date)
    
    date_from_json = ActiveSupport::JSON.decode(json).to_date
    date_from_json.precision.should == date.precision
  end

  context 'when formatting as a string' do
    require 'date_time_precision/format/string'

    it 'takes precision into account for the :long format' do
      Date.new(2000).to_s(:long).should == "2000"
      Date.new(2000, 8).to_s(:long).should == "August 2000"
      Date.new(2000, 3, 9).to_s(:long).should == "March  9, 2000"

      DateTime.new(1800).to_s(:long).should == "1800"
      DateTime.new(1990, 8).to_s(:long).should == "August 1990"
      DateTime.new(-50, 3, 9).to_s(:long).should == "March 09, -0050"
      DateTime.new(2004, 7, 8, 10).to_s(:long).should == "July 08, 2004"
      DateTime.new(2004, 7, 8, 10, 5).to_s(:long).should == "July 08, 2004 10:05"

      Time.mktime(1800).to_s(:long).should == "1800"
      Time::mktime(1990, 8).to_s(:long).should == "August 1990"

      # Every Ruby seems to have a different idea about how to format this exactly
      Time::mktime(-50, 3, 9).to_s(:long).should match /^March 09, 0*\-0*50$/

      Time::mktime(2004, 7, 8, 10).to_s(:long).should == "July 08, 2004"
      Time::mktime(2004, 7, 8, 10, 5).to_s(:long).should == "July 08, 2004 10:05"
    end
  end
end