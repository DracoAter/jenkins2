require 'simplecov'

SimpleCov.start do
	add_filter '/test/'
	coverage_dir 'test/coverage/integration'
end

require 'minitest/autorun'
require 'mocha/setup'

require_relative '../../lib/jenkins2'

# We do not want any logging in tests
Jenkins2::Log.init( log: STDOUT, verbose: -1 )

# Setup subject just once
class Minitest::Test
		ENV['JENKINS2_SERVER'] =  'http://' + `kitchen diagnose | grep -oP "(?<=hostname:\\s).*$"`.strip + ':8080'
		ENV['JENKINS2_KEY'] = `kitchen exec -c "cat /var/lib/jenkins/secrets/initialAdminPassword"`.split("\n").last.strip
		ENV['JENKINS2_USER'] = 'admin'
	@@key = ENV['JENKINS2_KEY']
	@@server = ENV['JENKINS2_SERVER']
	@@user = ENV['JENKINS2_USER']
	@@subj = Jenkins2::Client.new( server: @@server, user: @@user, key: @@key )

	# Restart Jenkins before running the tests, to make sure all changes are applied.
	# For example uninstalling plugin, requires restart.
	# Required to make sure you can run tests as many times you need in a row.
	@@subj.restart!

	# Make sure Jenkins is ready and listening
	Jenkins2::Try.try{ @@subj.version }
end
