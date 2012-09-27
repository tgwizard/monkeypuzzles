require 'rubygems'

require 'rake'
require 'rake/testtask'

desc "Run all tests"
task :test do
  Rake::TestTask.new do |t|
    t.libs << "test"
    t.pattern = "test/**/*_test.rb"
    t.verbose = true
  end
end

desc "Start the dev server with shotgun"
task :shotgun do
  sh "shotgun --debug -p 4567 ./src/main.rb"
end

task :sinatra do
  sh "bundle exec thin --debug --rackup config.ru -p 4567 start"
end
