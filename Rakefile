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

	Rake::TestTask.new :integration do |t|
		t.verbose = true
		t.warning = true
		t.test_files = FileList['test/integration/*_test.rb']
	end
end
if ENV['GENERATE_REPORTS'] == 'true'
	require 'ci/reporter/rake/minitest'
	task 'test:_unit' do
		ENV['CI_REPORTS'] = 'test/unit/reports'
		Rake::Task['ci:setup:minitest'].invoke
	end
	task 'test:unit' => 'test:_unit'
	task 'test:_integration' do
		ENV['CI_REPORTS'] = 'test/integration/reports'
		Rake::Task['ci:setup:minitest'].invoke
	end
	task 'test:integration' => 'test:_integration'
end
CLEAN << 'test/unit/reports'
CLEAN << 'test/unit/coverage'
CLEAN << 'test/integration/reports'
CLEAN << 'test/integration/coverage'

Gem::PackageTask.new( Gem::Specification.load( 'jenkins2.gemspec' ) ) do end
CLEAN << 'pkg'

task :install => :gem do |t|
	Gem::Installer.new( "pkg/jenkins2-#{Jenkins2::VERSION}.gem", user_install: Process.uid != 0 ).install
end

task :bootstrap do |t|
	Gem::Specification.load( 'jenkins2.gemspec' ).development_dependencies.each do |dp|
		unless Gem::Installer.new( '' ).installation_satisfies_dependency? dp
			Gem::DependencyInstaller.new( user_install: Process.uid != 0 ).install( dp )
		end
	end
end
