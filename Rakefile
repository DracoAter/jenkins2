# frozen_string_literal: true

require 'rake/testtask'
require 'rake/clean'
require 'rubygems/package_task'
require 'rubygems/dependency_installer'

CLEAN << 'doc'

task default: %i[test:unit]

namespace :test do
	CLEAN << 'test/coverage'
	CLEAN << 'test/integration.log'

	%w[unit integration].each do |name|
		Rake::TestTask.new name do |t|
			t.description = "Run #{name} tests and generate coverage reports."
			t.verbose = true
			t.warning = true
			t.test_files = FileList["test/#{name}/*_test.rb"]
		end
	end

	desc 'Run all tests and generate coverage reports.'
	task all: %i[unit integration]
end

namespace :ci do
	CLEAN << 'test-reports'

	%w[all unit integration].each do |name|
		desc "Run #{name} tests and generate report for CI"
		task name do
			ENV['CI_REPORTS'] = 'test-reports/'
			require 'ci/reporter/rake/minitest'
			Rake::Task['ci:setup:minitest'].invoke
			Rake::Task["test:#{name}"].invoke
		end
	end
end

begin
	require 'rubocop/rake_task'
	RuboCop::RakeTask.new(:rubocop) do |t|
		t.options = ['--display-cop-names']
	end
	task 'test:unit' => :rubocop
rescue LoadError
	puts "Rubocop not found. It's rake tasks are disabled."
end

Gem::PackageTask.new(Gem::Specification.load('jenkins2.gemspec')){}

desc 'Install this gem locally'
task :install, [:user_install] => :gem do |_t, args|
	args.with_defaults(user_install: false)
	Gem::Installer.new("pkg/jenkins2-#{Jenkins2::VERSION}.gem", user_install: args.user_install).
		install
end

namespace :dependencies do
	desc 'Install development dependencies'
	task :install do |_t|
		installer = Gem::Installer.new('')
		unsatisfied_dependencies = Gem::Specification.load('jenkins2.gemspec').
			development_dependencies.reject do |dp|
			installer.installation_satisfies_dependency?(dp)
		end
		next if unsatisfied_dependencies.empty?
		unsatisfied_dependencies.each do |dp|
			# If CI is set to `true`, it is most probably ci server, so we go with user_install.
			Gem::DependencyInstaller.new(user_install: ENV['CI'] == 'true').install(dp)
		end
	end
end
