require 'rubygems'
require 'bundler'
Bundler.setup

Dir['./spec/support/**/*.rb'].map {|f| require f}

RSpec.configure do |c|
  c.color = true
end