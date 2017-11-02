require 'simplecov'

SimpleCov.start do
	add_filter '/test/'
	coverage_dir 'test/coverage/unit'
end

require 'minitest/autorun'
require 'mocha/setup'

require_relative '../../lib/jenkins2'

# We do not want any logging in tests
Jenkins2::Log.init( verbose: 3 )
