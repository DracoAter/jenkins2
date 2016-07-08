require 'uri'
require 'mocha'
require_relative 'test_helper'

class LogTest < Minitest::Test
	def test_log_calls_ruby_logger
		Logger.any_instance.expects( :info ).twice
		Jenkins::Log.info 'test'
		Jenkins::Log.info{ 'test' }

		Logger.any_instance.expects( :debug ).twice
		Jenkins::Log.debug 'test'
		Jenkins::Log.debug{ 'test' }
	end
end
