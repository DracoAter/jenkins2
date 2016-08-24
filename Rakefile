require 'rake/testtask'
require 'rake/clean'
require 'rubygems/package_task'
require 'rubygems/dependency_installer'

CLEAN << 'doc'

task :default => 'test:unit'

namespace :test do
	Rake::TestTask.new :unit do |t|
		t.verbose = true
		t.warning = true
		t.test_files = FileList['test/unit/*_test.rb']
	end
	CLEAN << 'coverage'

	Rake::TestTask.new :integration do |t|
		t.verbose = true
		t.warning = true
		t.test_files = FileList['test/integration/*_test.rb']
	end
	CLEAN << 'test/integration/ip'
	CLEAN << 'test/integration/key'
end

if ENV['GENERATE_REPORTS'] == 'true'
	require 'ci/reporter/rake/minitest'
	task 'test:unit' => 'ci:setup:minitest'
	task 'test:integration' => 'ci:setup:minitest'
end
CLEAN << 'test/reports'

Gem::PackageTask.new( Gem::Specification.load( 'jenkins2.gemspec' ) ) do end
CLEAN << 'pkg'

task :install => :gem do |t|
	if Process.uid == 0
		sh "gem install pkg/jenkins2-#{Jenkins2::VERSION}.gem"
	else
		puts 'Running as non-root. Installing into user space.'
		sh "gem install --user-install pkg/jenkins2-#{Jenkins2::VERSION}.gem"
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
