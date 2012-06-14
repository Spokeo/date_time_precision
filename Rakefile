#!/usr/bin/env rake
require "bundler/gem_tasks"

Dir['gem_tasks/**/*.rake'].each { |rake| load rake }

task :default => [:spec, :active_support_spec]