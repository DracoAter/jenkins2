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
				out, err = capture_subprocess_io do
					assert_raises( Errno::ECONNREFUSED ) do
						Try.try( retry_delay: 0 ){ puts '1'; raise Errno::ECONNREFUSED.new }
					end
				end
				assert_equal "1\n1\n1\n", out
				out, err = capture_subprocess_io do
					assert_raises( Net::HTTPFatalError ) do
						Try.try( retry_delay: 0 ){ puts '2'; raise Net::HTTPFatalError.new( 'a', 'b' ) }
					end
				end
				assert_equal "2\n2\n2\n", out
			end
		end
	end
end
