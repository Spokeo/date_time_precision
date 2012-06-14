require 'rspec/core/rake_task'

desc "Run RSpec"
RSpec::Core::RakeTask.new do |t|
  t.verbose = true
  t.pattern = "spec/date_time_precision/date_time_precision_spec.rb"
end

desc "Run ActiveSupport spec"
RSpec::Core::RakeTask.new(:active_support_spec) do |t|
  t.verbose = true
  t.pattern = "spec/date_time_precision/active_support_spec.rb"
end