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
	@@key = ENV['JENKINS2_KEY']
	@@server = ENV['JENKINS2_SERVER']
	@@user = ENV['JENKINS2_USER']
	@@subj = Jenkins2::Client.new( server: @@server, user: @@user, key: @@key )
	# Make sure Jenkins is ready and listening
	Jenkins2::Try.try{ @@subj.version }
end
