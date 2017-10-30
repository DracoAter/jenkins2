require_relative 'test_helper'

module Jenkins2
	module UnitTest
		class UtilTest < Minitest::Test
			def test_try_return_block_result
				assert_equal 456, Util.try{ 456 }
				assert Util.try{ true }
				assert_nil Util.try{ nil }
			end

			def test_try_raises_error_after_retries_connection_refused
				i = 0
				assert_raises( Errno::ECONNREFUSED ) do
					Util.try( retry_delay: 0 ){ i += 1; raise Errno::ECONNREFUSED }
				end
				assert_equal 3, i
			end

			def test_try_raises_error_after_retries_http_fatal_error
				i = 0
				assert_raises( Net::HTTPFatalError ) do
					Util.try( retry_delay: 0 ){ i += 2; raise Net::HTTPFatalError.new( 'a', 'b' ) }
				end
				assert_equal 6, i
			end

			def xtest_try_raises_error_after_retries_read_timeout
				i = 0
				assert_raises( Net::ReadTimeout ) do
					Util.try( retry_delay: 0 ){ i += 5; raise Net::ReadTimeout }
				end
				assert_equal 15, i
			end

			def xtest_try_raises_error_straight_away
				i = 0
				assert_raises( StandardError ) do
					Util.try( retry_delay: 0 ){ i += 1; raise StandardError }
				end
				assert_equal 1, i
			end
		end
	end
end
