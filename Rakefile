require 'rake/testtask'

Rake::TestTask.new do |t|
	t.pattern = "test/*_test.rb"
end

desc "Run tests"
task :default => :test

desc 'Install gem locally'
task :install do |t|
	sh 'gem build jenkins_tips.gemspec'
	sh 'sudo gem install ./jenkins_tips-0.0.0.gem'
end
