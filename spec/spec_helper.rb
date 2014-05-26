require 'rubygems'
require 'bundler/setup'

require 'pry'

Dir['./spec/support/**/*.rb'].map {|f| require f}

RSpec.configure do |c|
  c.color = true
end