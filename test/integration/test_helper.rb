require 'simplecov'
require 'minitest/autorun'
require 'mocha/setup'

require_relative '../../lib/jenkins2'

# We do not want any logging in tests
Jenkins2::Log.init( verbose: 3 )

# Setup subject just once
class Minitest::Test
	@@opts = { server: ENV['JENKINS2_SERVER'], user: ENV['JENKINS2_USER'],
		key: ENV['JENKINS2_KEY'] }
	@@subj = Jenkins2.connect @@opts

	# Restart Jenkins before running the tests, to make sure all pending changes are applied.
	# For example uninstalling plugin, requires restart.
	# Required to make sure you can run tests as many times you need in a row.
	@@subj.restart!

	# Make sure Jenkins is ready and listening
	Jenkins2::Util.wait( max_wait_minutes: 2 ){ @@subj.version }
end
