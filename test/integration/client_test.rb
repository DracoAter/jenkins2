require 'uri'
require 'mocha'
require_relative 'test_helper'

module Jenkins2
	module IntegrationTest
		class ClientTest < Minitest::Test
			def test_version
				assert_equal '2.73.1', @@subj.version
			end
		end
	end
end
