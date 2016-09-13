require 'uri'
require 'mocha'
require_relative 'test_helper'

module Jenkins2
	module UnitTest
		class TryTest < Minitest::Test
			def test_try_return_block_result
				assert_equal 456, Try.try{ 456 }
				assert Try.try{ true }
				assert_nil Try.try{ nil }
			end

			def test_try_raises_exception_after_retries
				i = 0
				assert_raises( Errno::ECONNREFUSED ) do
					Try.try( retry_delay: 0 ){ i += 1; raise Errno::ECONNREFUSED.new }
				end
				assert_equal 3, i
				assert_raises( Net::HTTPFatalError ) do
					Try.try( retry_delay: 0 ){ i += 2; raise Net::HTTPFatalError.new( 'a', 'b' ) }
				end
				assert_equal 9, i
			end
		end
	end
end
