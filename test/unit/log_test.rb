require 'uri'
require 'mocha'
require_relative 'test_helper'

module Jenkins2
	module UnitTest
		class LogTest < Minitest::Test
			def test_log_calls_ruby_logger
				Logger.any_instance.expects( :info ).twice
				Log.info 'test'
				Log.info{ 'test' }

				Logger.any_instance.expects( :debug ).twice
				Log.debug 'test'
				Log.debug{ 'test' }
			end
		end
	end
end
