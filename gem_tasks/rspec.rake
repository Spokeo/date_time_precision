require 'rspec/core/rake_task'

desc "Run RSpec"
RSpec::Core::RakeTask.new do |t|
  t.verbose = true
  t.pattern = 'spec/**/*.{spec,rb}'
end