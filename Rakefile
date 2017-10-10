require 'rake/testtask'
require 'rake/clean'
require 'rubygems/package_task'
require 'rubygems/dependency_installer'
require 'ci/reporter/rake/minitest'

CLEAN << 'doc'

task :default => 'test:unit'

namespace :test do
	%w{unit integration}.each do |name|
		Rake::TestTask.new name do |t|
			t.verbose = true
			t.warning = true
			t.deps = ["test:#{name}:report"] if t.respond_to? :deps=
			t.test_files = FileList["test/#{name}/*_test.rb"]
		end

		namespace name do
			task :report do |t, args|
				next unless ENV['GENERATE_REPORTS']
				ENV['CI_REPORTS'] = "test/reports/#{name}"
				Rake::Task['ci:setup:minitest'].invoke
			end
		end
	end
	CLEAN << "test/coverage"
	CLEAN << 'test/reports'

	task :integration => :get_credentials

	task :get_credentials do |t|
		ENV['JENKINS2_SERVER'] =  'http://' + `lxc info j | grep "eth0:\\sinet\\s" | cut -f3`.strip + ':8080'
		ENV['JENKINS2_KEY'] = `lxc exec j cat -- /var/lib/jenkins/secrets/initialAdminPassword`.strip
		ENV['JENKINS2_USER'] = 'admin'
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
			# If environment is set to `citest`, it is most probably ci server, so we go with user_install.
			Gem::DependencyInstaller.new( user_install: ENV['RUBY_ENV'] == 'citest' ).install( dp )
		end
	end
end
