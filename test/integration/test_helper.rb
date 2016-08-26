require 'simplecov'

SimpleCov.start do
	add_filter '/test/'
	coverage_dir 'test/integration/coverage'
end

require 'minitest/autorun'
require 'mocha/setup'

require_relative '../../lib/jenkins2'

# We do not want any logging in tests
Jenkins2::Log.init( log: STDOUT, verbose: -1 )

# Setup subject just once
class Minitest::Test
	@@key = IO.read( 'test/integration/key' ).strip
	@@ip = IO.read( 'test/integration/ip' ).strip
	@@subj = Jenkins2::Client.new( server: "http://#{@@ip}:8080", user: 'admin', key: @@key )
	# Make sure Jenkins is ready and listening
	Jenkins2::Try.try{ @@subj.version }
end
