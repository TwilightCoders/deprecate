require "bundler/gem_tasks"

desc "Run tests"  
task :test do
  sh "ruby -I lib test/test_deprecate_simple.rb"
end

desc "Run manual verification"
task :manual do
  sh "ruby -I lib test_manual.rb"  
end

task :default => :test

