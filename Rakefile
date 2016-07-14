require 'rake/testtask'
require 'rubygems/package_task'
require 'rubygems/dependency_installer'

task :default => :test

Rake::TestTask.new do |t|
	t.pattern = "test/*_test.rb"
end

Gem::PackageTask.new( Gem::Specification.load( 'jenkins.gemspec' ) ) do end

task :install => :gem do |t|
	if Process.uid == 0
		sh 'gem install pkg/jenkins-0.0.0.gem -N'
	else
		puts 'Running as non-root. Installing into user space.'
		sh 'gem install --user-install pkg/jenkins-0.0.0.gem -N'
	end
end

task :bootstrap do |t|
	if Process.uid == 0
		Gem::Specification.load( 'jenkins.gemspec' ).development_dependencies.each do |dp|
			Gem::DependencyInstaller.new.install( dp )
		end
	else
		puts 'Running as non-root. Installing into user space.'
		Gem::Specification.load( 'jenkins.gemspec' ).development_dependencies.each do |dp|
			Gem::DependencyInstaller.new( user_install: true ).install( dp )
		end
	end
end
