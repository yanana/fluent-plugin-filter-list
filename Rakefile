require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rubocop/rake_task'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test' << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
end

RuboCop::RakeTask.new

task default: %w[rubocop test]
