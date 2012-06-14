# -*- encoding: utf-8 -*-
require File.expand_path('../lib/date_time_precision/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["David Butler"]
  gem.email         = ["dwbutler@ucla.edu"]
  gem.description   = %q{Patches Date, Time, and DateTime ruby classes to keep track of precision}
  gem.summary       = %q{Patches Date, Time, and DateTime ruby classes to keep track of precision}
  gem.homepage      = "http://github.com/Spokeo/date_time_precision"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "date_time_precision"
  gem.require_paths = ["lib"]
  gem.version       = DateTimePrecision::VERSION
  
  gem.required_ruby_version      = '>= 1.8.7'
  gem.add_development_dependency 'rake', '>= 0.9.2'
  gem.add_development_dependency 'rspec', '~> 2.10.0'
  gem.add_development_dependency 'activesupport'
  #gem.add_development_dependency 'ruby-debug'
  #gem.add_development_dependency 'ruby-debug19'
end
