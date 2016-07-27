require 'rake/testtask'
require 'rubygems/package_task'
require 'rubygems/dependency_installer'

task :default => :test

Rake::TestTask.new do |t|
	t.verbose = true
	t.warning = true
	t.test_files = FileList['test/*_test.rb']
end

if ENV['GENERATE_REPORTS'] == 'true'
	require 'ci/reporter/rake/minitest'
	task :test => 'ci:setup:minitest'
end

Gem::PackageTask.new( Gem::Specification.load( 'jenkins2.gemspec' ) ) do end

task :install => :gem do |t|
	if Process.uid == 0
		sh 'gem install pkg/jenkins2-0.0.0.gem -N'
	else
		puts 'Running as non-root. Installing into user space.'
		sh 'gem install --user-install pkg/jenkins2-0.0.0.gem -N'
	end
end

task :bootstrap do |t|
	if Process.uid == 0
		Gem::Specification.load( 'jenkins2.gemspec' ).development_dependencies.each do |dp|
			Gem::DependencyInstaller.new.install( dp )
		end
	else
		puts 'Running as non-root. Installing dependencies into user space.'
		Gem::Specification.load( 'jenkins2.gemspec' ).development_dependencies.each do |dp|
			Gem::DependencyInstaller.new( user_install: true ).install( dp )
		end
	end
end
