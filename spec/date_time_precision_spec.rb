require 'spec_helper'
require 'date_time_precision'

describe DateTimePrecision do
  context 'Constructors' do
    it 'has no precision for unspecified date' do
      d = Date.new
      d.precision.should == DateTimePrecision::NONE
      d.year?.should be_false
    
      dt = DateTime.new
      dt.precision.should == DateTimePrecision::NONE
      dt.year?.should be_false
    end
  
    it 'has no precision for nil values' do
      nil.precision.should == DateTimePrecision::NONE
    end
  
    it 'has year precision when only year is supplied' do
      d = Date.new(1982)
      d.precision.should == DateTimePrecision::YEAR
      d.year?.should be_true
      d.month?.should be_false
      d.day?.should be_false
    end
  
    it 'has month precision when year and month are supplied' do
      d = Date.new(1982, 11)
      d.precision.should == DateTimePrecision::MONTH
      d.year?.should be_true
      d.month?.should be_true
      d.day?.should be_false
    end
  
    it 'has day precision when year, month, and day are passed in' do
      dt = DateTime.new(1987,10,19)
      dt.precision.should == DateTimePrecision::DAY
      dt.year?.should be_true
      dt.month?.should be_true
      dt.day?.should be_true
      dt.hour?.should be_false
    end
  
    it 'has hour precision' do
      dt = DateTime.new(1970, 1, 2, 3)
      dt.precision.should == DateTimePrecision::HOUR
      dt.year?.should be_true
      dt.month?.should be_true
      dt.day?.should be_true
      dt.hour?.should be_true
      dt.min?.should be_false
    end
    
    it 'tracks which attributes were explicitly set separately from precision' do
      [Date.new(nil, 11, 12), DateTime.new(nil, 10, 11, nil), Time.mktime(nil, 12, 13, nil, 14)].each do |d|
        d.year?.should be_false
        d.month?.should be_true
        d.day?.should be_true
        d.hour?.should be_false
        d.min?.should be_true if d.is_a? Time
        d.precision.should == DateTimePrecision::NONE
      end
    end
  
    it 'has max precision for fully specified dates/times' do
      # Time.new is an alias for Time.now
      [Time.new, Time.now, DateTime.now, Date.today].each do |t|
        t.precision.should == t.class::MAX_PRECISION
      end
    end
    
    it 'accepts nil values in the constructor' do
      Date.new(nil).precision.should == DateTimePrecision::NONE
      Date.new(2000, nil).precision.should == DateTimePrecision::YEAR
      DateTime.new(2000, 1, nil).precision.should == DateTimePrecision::MONTH
      Time.mktime(2000, 1, 1, nil, nil).precision.should == DateTimePrecision::DAY
    end
  end
  
  context 'Time Zones' do
    it 'should retain precision when switching to UTC' do
      Time.mktime(2000).utc.precision.should == DateTimePrecision::YEAR
      Time.mktime(2000).gmtime.precision.should == DateTimePrecision::YEAR
    end
    
    it 'should track precision when creating a time in UTC' do
      Time.utc(1945, 10).precision.should == DateTimePrecision::MONTH
      Time.gm(1945, 10).precision.should == DateTimePrecision::MONTH
    end
    
    it 'should track precision when creating a time in the local timezone' do
      Time.local(2004, 5, 6).precision.should == DateTimePrecision::DAY
    end
  end

  context 'Parsing' do
    it 'should have second/frac precision when parsing a timestamp' do
      t = Time::parse('2000-2-3 00:00:00 UTC')
      t.precision.should == DateTimePrecision::SEC
      t.year.should == 2000
      t.month.should == 2
      t.day.should == 3
    end
  
    it 'should have minute precision when seconds are not in the timestamp' do
      dt = DateTime::parse('2000-1-1 00:00 EST') # => Sat, 01 Jan 2000 00:00:00 -0500
      dt.precision.should == DateTimePrecision::MIN
      dt.year.should == 2000
      dt.day.should == 1
    end
  
    it 'should have day precision wehn parsing into a Date object' do
      d = Date::parse('2000-1-1 00:00:00 EST') # => Sat, 01 Jan 2000
      d.precision.should == DateTimePrecision::DAY
    end
  
    it 'should have month precision when day is not in the parsed string' do
      t = Time::parse('January 2000 UTC').utc # => Sat Jan 01 00:00:00 -0800 2000
      t.precision.should == DateTimePrecision::MONTH
      t.year.should == 2000
      t.month.should == 1
    end
  end

  context 'strptime' do
    it 'should have day precision when day is specified in date string' do
      d = Date.strptime('02/09/1968', '%m/%d/%Y')
      d.precision.should == DateTimePrecision::DAY
    end
  
    it 'should have minute precision when extracting down to the minute' do
      dt = DateTime.strptime('2011-02-03 15:14:52','%Y-%m-%d %H:%M')
      dt.precision.should == DateTimePrecision::MIN
    end
  
    it 'should have second precision when extracting down to the second' do
      t = DateTime.strptime('2011-02-03 15:14:52','%Y-%m-%d %H:%M:%S')
      t.precision.should == DateTimePrecision::SEC
    end
  end

  context 'Addition' do
    it 'should default to max precision when adding or subtracting' do
      d = Date.new
      d.precision.should == DateTimePrecision::NONE
      d += 3
      d.precision.should == Date::MAX_PRECISION
      d -= 2
      d.precision.should == Date::MAX_PRECISION
    
      dt = DateTime.new
      dt.precision.should == DateTimePrecision::NONE
      dt += 3
      dt.precision.should == DateTime::MAX_PRECISION
      dt -= 2
      dt.precision.should == DateTime::MAX_PRECISION
    
      t = Time::parse('January 2000 UTC').utc
      t.precision.should == DateTimePrecision::MONTH
      t += 10
      t.precision.should == Time::MAX_PRECISION
      t -= 8
      t.precision.should == Time::MAX_PRECISION
    end
  end

 context 'Partial Matching' do
    it 'should match when differing only in day precision' do
      d1 = Date.new(2001,3,2)
      d2 = Date.new(2001,3)
      d1.partial_match?(d2).should be_true
      d2.partial_match?(d1).should be_true
    end
  end

end