require 'uri'
require 'mocha'
require_relative 'test_helper'

module IntegrationTest
	class ClientTest < Minitest::Test
		def test_version
			assert_equal '2.7.2', @@subj.version
		end
	end
end
