require 'rake/testtask'
require 'rubygems/package_task'

Rake::TestTask.new do |t|
	t.pattern = "test/*_test.rb"
end

task :default => :test

Gem::PackageTask.new( Gem::Specification.load( 'jenkins.gemspec' ) ) do end
