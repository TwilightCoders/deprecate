require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

desc "Run manual verification"
task :manual do
  sh "ruby -I lib test_manual.rb"
end

task :default => :spec
