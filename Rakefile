require "bundler/gem_tasks"
require 'rspec/core/rake_task'

require 'devtools'
Devtools.init_rake_tasks

RSpec::Core::RakeTask.new(:spec)

task :default => :spec
