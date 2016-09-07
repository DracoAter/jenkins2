require 'uri'
require 'mocha'
require_relative 'test_helper'

module Jenkins2
	module UnitTest
		class URITest < Minitest::Test
			def test_escape_does_escaping_right
				assert_equal '/path%20with/spaces%20/', URI.escape( '/path with/spaces /' )
				assert_equal '/path+with/pluses+/', URI.escape( '/path+with/pluses+/' )
				assert_equal '/pathwith?params=4&here=7', URI.escape( '/pathwith?params=4&here=7' )
			end
		end
	end
end
