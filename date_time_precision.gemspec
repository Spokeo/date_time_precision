# -*- encoding: utf-8 -*-
require File.expand_path('../lib/date_time_precision/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["David Butler"]
  gem.email         = ["dwbutler@ucla.edu"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "date_time_precision"
  gem.require_paths = ["lib"]
  gem.version       = DateTimePrecision::VERSION
end
