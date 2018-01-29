require 'rake/testtask'
require 'rake/clean'
require 'rubygems/package_task'
require 'rubygems/dependency_installer'

CLEAN << 'doc'
CLEAN << 'test/coverage'
CLEAN << 'test/reports'

task :default => 'test:unit'

namespace :test do
	%w{unit integration}.each do |name|
		Rake::TestTask.new name do |t|
			t.description = "Run #{name} tests and generate coverage reports."
			t.verbose = true
			t.warning = true
			t.test_files = FileList["test/#{name}/*_test.rb"]
		end
	end


	desc 'Run all tests and generate coverage reports.'
	task :all => [:unit, :integration]

	task :integration => :get_credentials
	task :get_credentials do |t|
		ENV['JENKINS2_SERVER'] =  'http://' + `kitchen diagnose | grep -oP "(?<=hostname:\\s).*$"`.strip + ':8080'
		ENV['JENKINS2_KEY'] = `kitchen exec -c "cat /var/lib/jenkins/secrets/initialAdminPassword"`.split("\n").last.strip
		ENV['JENKINS2_USER'] = 'admin'
	end
end

namespace :ci do
	%w{all unit integration}.each do |name|
		desc "Run #{name} tests and generate report for CI"
		task name do
			ENV['CI_REPORTS'] = "test/reports/"
			require 'ci/reporter/rake/minitest'
			Rake::Task['ci:setup:minitest'].invoke
			Rake::Task["test:#{name}"].invoke
		end
	end
end

Gem::PackageTask.new( Gem::Specification.load( 'jenkins2.gemspec' ) ) do end

desc 'Install this gem locally'
task :install, [:user_install] => :gem do |t, args|
	args.with_defaults( user_install: false )
	Gem::Installer.new( "pkg/jenkins2-#{Jenkins2::VERSION}.gem", user_install: args.user_install ).install
end

namespace :dependencies do
	desc 'Install development dependencies'
	task :install do |t|
		installer = Gem::Installer.new( '' )
		unsatisfied_dependencies = Gem::Specification.load( 'jenkins2.gemspec' ).development_dependencies.select do |dp|
			!installer.installation_satisfies_dependency?( dp )
		end
		next if unsatisfied_dependencies.empty?
		unsatisfied_dependencies.each do |dp|
			# If environment is set to `test`, it is most probably ci server, so we go with user_install.
			Gem::DependencyInstaller.new( user_install: ENV['RUBY_ENV'] == 'test' ).install( dp )
		end
	end
end
