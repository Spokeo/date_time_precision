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
  
    it 'should have day precision when year, month, and day are passed in' do
      dt = DateTime.new(1987,10,19)
      dt.precision.should == DateTimePrecision::DAY
      dt.year?.should be_true
      dt.month?.should be_true
      dt.day?.should be_true
      dt.hour?.should be_false
    end
  
    it 'should have hour precision' do
      dt = DateTime.new(1970, 1, 2, 3)
      dt.precision.should == DateTimePrecision::HOUR
      dt.year?.should be_true
      dt.month?.should be_true
      dt.day?.should be_true
      dt.hour?.should be_true
      dt.min?.should be_false
    end
  
    it 'should have max precision for fully specified dates/times' do
      # Time.new is an alias for Time.now
      [Time.new, Time.now, DateTime.now, Date.today].each do |t|
        t.precision.should == t.class::MAX_PRECISION
      end
    end
    
    it 'should accept nil values in the constructor' do
      Date.new(nil).precision.should == DateTimePrecision::NONE
      Date.new(2000, nil).precision.should == DateTimePrecision::YEAR
      DateTime.new(2000, 1, nil).precision.should == DateTimePrecision::MONTH
      Time.mktime(2000, 1, 1, nil, nil).precision.should == DateTimePrecision::DAY
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

  context 'Formats' do
    let(:date) { Date.new(1989, 3, 11) }
    let(:datetime) { DateTime.new(1989, 3, 11, 8, 30, 15) }
    let(:time) do
      args = [1989, 3, 11, 8, 30, 15]
      args << 1 if Time::MAX_PRECISION == DateTimePrecision::FRAC
      Time.mktime(*args)
    end
    
    context 'Hash' do
      let(:date_hash) do
        {
          :year => 1989,
          :mon => 3,
          :mday => 11
        }
      end
    
      let(:datetime_hash) do
        {
          :year => 1989,
          :mon => 3,
          :mday => 11,
          :hour => 8,
          :min => 30,
          :sec => 15,
        }
      end
    
      let(:time_hash) do
        @time_hash = datetime_hash
        @time_hash.merge!(:sec_frac => 1) if Time::MAX_PRECISION == DateTimePrecision::FRAC
        @time_hash
      end
    
      context 'Converting to hash' do
        it 'should convert Date to a hash' do
          date.to_h.should == date_hash
        end
      
        it 'should convert DateTime to a hash' do
          datetime.to_h.should == datetime_hash
        end
      
        it 'should convert Time to a hash' do
          time.to_h.should == time_hash
        end
      end
      
      context 'Converting to hash with format' do
        let(:short_date_hash) do
          {
            :y => 1989,
            :m => 3,
            :d => 11
          }
        end
        
        let(:long_date_hash) do
          {
            :year => 1989,
            :month => 3,
            :day => 11
          }
        end
        
        it 'should convert Date to a short hash' do
          date.to_h(:short).should == short_date_hash
        end
      
        it 'should convert DateTime to a long hash' do
          datetime.to_h(:long).should == long_date_hash
        end
      
        it 'should convert Time to a custom hash' do
          Hash::DATE_FORMATS[:custom] = [:year, :mon, :d, :h, :min, :s]
          
          time.to_h(:custom).should == {
            :year => 1989,
            :mon => 3,
            :d => 11,
            :h => 8,
            :min => 30,
            :s => 15,
          }
        end
        
        it 'should convert to the default hash format' do
          Hash::DATE_FORMATS[:default] = Hash::DATE_FORMATS[:short]
          date.to_h(:short).should == short_date_hash
          Hash::DATE_FORMATS[:default] = Hash::DATE_FORMATS[:ruby]
        end
      end
  
      context 'Converting from hash' do
        it 'should convert a hash to a Date' do
          date_hash.to_date.should == date
        end
    
        it 'should convert a hash to a DateTime' do
          datetime_hash.to_datetime.should == datetime
        end
    
        it 'should convert a hash to a Time' do
          time_hash.to_time.should == time
        end
      
        it 'should accept flexible keys' do
          {
            :y => 1989,
            :m => 3,
            :d => 11
          }.to_date.should == date
        
          {
            :year => 1989,
            :month => 3,
            :day => 11
          }.to_date.should == date
        end
      end
    end
  
    context 'JSON' do
      require 'date_time_precision/format/json'
      require 'json'
    
      it 'should convert a date to a JSON hash' do
        date.as_json.should == date.to_h
        date.to_json.should == date.to_h.to_json
      end
    
      it 'should convert a datetime to a JSON hash' do
        datetime.as_json.should == datetime.to_h
        datetime.to_json.should == datetime.to_h.to_json
      end
      
      it 'should convert a time to a JSON hash' do
        time.as_json.should == time.to_h
        time.to_json.should == time.to_h.to_json
      end
    end
    
  end
end