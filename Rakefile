require 'rake/testtask'
require 'rubygems/package_task'
require 'rubygems/dependency_installer'

task :default => :test

Rake::TestTask.new do |t|
	t.pattern = "test/*_test.rb"
end

Gem::PackageTask.new( Gem::Specification.load( 'jenkins.gemspec' ) ) do end

task :install => :gem do |t|
	raise 'Must run as root' unless Process.uid == 0
	sh 'gem install pkg/jenkins-0.0.0.gem -N'
end

task :bootstrap do |t|
	raise 'Must run as root' unless Process.uid == 0
	Gem::Specification.load( 'jenkins.gemspec' ).development_dependencies.each do |dp|
		Gem::DependencyInstaller.new.install( dp )
	end
end
