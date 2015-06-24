require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "cucumber/rake/task"
require "coveralls/rake/task"

RSpec::Core::RakeTask.new(:spec)
Cucumber::Rake::Task.new(:features)
Coveralls::RakeTask.new

task test_with_coveralls: [:spec, :features, "coveralls:push"]
