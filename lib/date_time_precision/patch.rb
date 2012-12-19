require 'date_time_precision/lib'

require 'date_time_precision/patch/nil'
Dir["#{File.dirname(__FILE__)}/patch/#{RUBY_VERSION}/*.rb"].each {|f| require f }