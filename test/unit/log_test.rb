require 'uri'
require 'mocha'
require_relative 'test_helper'

class LogTest < Minitest::Test
	def test_log_calls_ruby_logger
		Logger.any_instance.expects( :info ).twice
		Jenkins2::Log.info 'test'
		Jenkins2::Log.info{ 'test' }

		Logger.any_instance.expects( :debug ).twice
		Jenkins2::Log.debug 'test'
		Jenkins2::Log.debug{ 'test' }
	end
end
