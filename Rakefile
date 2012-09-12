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
task :sinatra do
	sh "shotgun --debug -p 4567 ./src/main.rb"
end
