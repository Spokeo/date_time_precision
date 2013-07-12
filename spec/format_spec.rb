require 'spec_helper'
require 'date_time_precision'

describe DateTimePrecision do
  
  context 'when formatting as' do
    let(:date) { Date.new(1989, 3, 11) }
    let(:datetime) { DateTime.new(1989, 3, 11, 8, 30, 15) }
    let(:time) do
      args = [1989, 3, 11, 8, 30, 15]
      args << 1 if Time::MAX_PRECISION == DateTimePrecision::FRAC
      Time.mktime(*args)
    end
    
    context 'ISO 8601' do
      require 'date_time_precision/format/iso8601'
      
      it 'should convert a date to ISO 8601' do
        date.iso8601.should == "1989-03-11"
        Date.new(1990, 5).iso8601.should == "1990-05"
        Date.new(1800).iso8601.should == "1800"
      end
      
      it 'should convert a datetime to ISO 8601' do
        datetime.iso8601.should == "1989-03-11T08:30:15Z"
        DateTime.new(1900).iso8601.should == "1900"
        DateTime.new(1990, 5).iso8601.should == "1990-05"
        DateTime.new(1990, 5, 2).iso8601.should == "1990-05-02"
        DateTime.new(1990, 5, 2, 12).iso8601.should == "1990-05-02T12Z"
        DateTime.new(1990, 5, 2, 12, 30).iso8601.should == "1990-05-02T12:30Z"
      end
      
      it 'should convert a time to ISO 8601' do
        Time.utc(1900).utc.iso8601.should == "1900"
        Time.mktime(1990, 5).utc.iso8601.should == "1990-05"
        Time.mktime(1990, 5, 2).utc.iso8601.should == "1990-05-02"
        Time.utc(1990, 5, 2, 12).iso8601.should == "1990-05-02T12Z"
        Time.utc(1990, 5, 2, 12, 30).utc.iso8601.should == "1990-05-02T12:30Z"
        Time.utc(1990, 5, 2, 12, 30, 45).utc.iso8601.should == "1990-05-02T12:30:45Z"
      end
    end
    
    context 'Hash' do
      require 'date_time_precision/format/hash'
    
      let(:date_hash) do
        {
          :year => 1989,
          :mon => 3,
          :day => 11
        }
      end
    
      let(:datetime_hash) do
        {
          :year => 1989,
          :mon => 3,
          :day => 11,
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
        
        it 'should skip year if not included' do
          Date.new(nil, 8, 10).to_h.should == {:mon => 8, :day => 10}
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

        it 'should convert Date to a long hash' do
          date.to_h(:long).should == long_date_hash
        end
      
        it 'should convert DateTime to a long hash' do
          datetime.to_h(:long).should == {
            :year => 1989,
            :month => 3,
            :day => 11,
            :hour => 8,
            :minute => 30,
            :second => 15
          }
        end

        it 'should convert Time to a short hash' do
          time.to_h(:short).should == {
            :y => 1989,
            :m => 3,
            :d => 11,
            :h => 8,
            :min => 30,
            :s => 15
          }
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
        
        it 'should only include fields that were set' do
          Date.new(nil, 3, 8).to_h.should == {:mon => 3, :day => 8}
          DateTime.new(nil, 5, 6, nil, 7).to_h.should == {:mon => 5, :day => 6, :min => 7}
          Time.mktime(nil, 1, nil, 9, nil, 10).to_h.should == {:mon => 1, :hour => 9, :sec => 10}
        end
      end
  
      context 'Converting from hash' do
        it 'converts a hash to a Date' do
          date_hash.to_date.should == date
        end
    
        it 'converts a hash to a DateTime' do
          datetime_hash.to_datetime.should == datetime
        end
    
        it 'converts a hash to a Time' do
          time_hash.to_time.should == time
        end
      
        it 'accepts flexible keys' do
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
        
        [:date, :datetime, :time].each do |klass|
          it "accepts month and day without year when converting to a #{klass}" do
            date = { :month => 5, :day => 18, :min => 48 }.send("to_#{klass}")
            date.year?.should be_false
            date.month?.should be_true
            date.month.should == 5
            date.day?.should be_true
            date.day.should == 18
            date.hour?.should be_false
            
            unless klass == :date
              date.min?.should be_true
              date.min.should == 48
            end
          end
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