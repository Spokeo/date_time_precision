require 'spec_helper'
require 'virtus'
require 'coercible'
require 'date_time_precision'
require 'date_time_precision/format/hash'

class VirtusModel
  include Virtus
  
  attribute :date, Date
  attribute :datetime, DateTime
  attribute :time, Time
end

describe DateTimePrecision do
  context 'compatibility' do
    
    let(:date_hash) { {:y => 1990} }
    let(:datetime_hash) { {'year' => 1800, 'mon' => 2} }
    let(:time_hash) { {:yr => 1950, 'm' => 5, :day => 19, :hr => 5} }
    
    context 'with Virtus' do
      require 'date_time_precision/compat/virtus'
      
      let(:model) { VirtusModel.new }
      before(:each) do
        model.date = date_hash
        model.datetime = datetime_hash
        model.time = time_hash
      end
      
      context 'when coercing a hash to a Date' do
        subject { model.date }
        
        it { should be_a Date }
        its(:year) { should == 1990 }
        its(:precision) { should == DateTimePrecision::YEAR }
      end
      
      context 'when coercing a hash to a DateTime' do
        subject { model.datetime }
        
        it { should be_a DateTime }
        its(:year) { should == 1800 }
        its(:month) { should == 2 }
        its(:precision) { should == DateTimePrecision::MONTH }
      end
      
      context 'when coercing a hash to a Time' do
        subject { model.time }
        
        it { should be_a Time }
        its(:year) { should == 1950 }
        its(:month) { should == 5 }
        its(:day) { should == 19 }
        its(:hour) { should == 5 }
        its(:precision) { should == DateTimePrecision::HOUR }
      end
    end
    
    context 'with Coercible' do
      require 'date_time_precision/compat/coercible'
      
      let(:coercer) { Coercible::Coercer::Hash.new }
      
      context 'when coercing a hash to a Date' do
        subject { coercer.to_date(date_hash) }
        
        it { should be_a Date }
        its(:year) { should == 1990 }
        its(:precision) { should == DateTimePrecision::YEAR }
      end
      
      context 'when coercing a hash to a DateTime' do
        subject { coercer.to_datetime(datetime_hash) }
        
        it { should be_a DateTime }
        its(:year) { should == 1800 }
        its(:month) { should == 2 }
        its(:precision) { should == DateTimePrecision::MONTH }
      end
      
      context 'when coercing a hash to a Time' do
        subject { coercer.to_time(time_hash) }
        
        it { should be_a Time }
        its(:year) { should == 1950 }
        its(:month) { should == 5 }
        its(:day) { should == 19 }
        its(:hour) { should == 5 }
        its(:precision) { should == DateTimePrecision::HOUR }
      end
    end
  end
end