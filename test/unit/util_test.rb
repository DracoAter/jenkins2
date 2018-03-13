# frozen_string_literal: true

require_relative 'test_helper'

module Jenkins2
	module UnitTest
		class UtilTest < Minitest::Test
			def test_try_return_block_result
				# rubocop:disable Lint/AmbiguousBlockAssociation
				assert_equal 456, Util.try{ 456 }
				assert_equal true, Util.try{ true }
				assert_nil Util.try{ nil }
				# rubocop:enable Lint/AmbiguousBlockAssociation
			end

			def test_try_raises_error_after_retries_connection_refused
				i = 0
				assert_raises(Errno::ECONNREFUSED) do
					Util.try(retry_delay: 0){ i += 1; raise Errno::ECONNREFUSED }
				end
				assert_equal 3, i
			end

			def test_try_raises_error_after_retries_http_fatal_error
				i = 0
				assert_raises(Net::HTTPFatalError) do
					Util.try(retry_delay: 0){ i += 2; raise Net::HTTPFatalError.new('a', 'b') }
				end
				assert_equal 6, i
			end

			def xtest_try_raises_error_after_retries_read_timeout
				i = 0
				assert_raises(Net::ReadTimeout) do
					Util.try(intervals: 0){ i += 5; raise Net::ReadTimeout }
				end
				assert_equal 15, i
			end

			def test_attempt_return_block_result
				# rubocop:disable Lint/AmbiguousBlockAssociation
				assert_equal 456, Util.attempt{ 456 }
				assert_equal true, Util.attempt{ true }
				assert_nil Util.attempt{ nil }
				# rubocop:enable Lint/AmbiguousBlockAssociation
			end

			def test_attempt_raises_error_straight_away
				i = 0
				assert_raises(StandardError) do
					Util.attempt(intervals: 0, on: nil){ i += 1; raise StandardError }
				end
				assert_equal 1, i
				assert_raises(StandardError) do
					Util.attempt(intervals: 0, on: []){ i += 1; raise StandardError }
				end
				assert_equal 2, i
			end

			def test_attempt_raises_error_after_retries_connection_refused
				i = 0
				assert_raises(Errno::ECONNREFUSED) do
					Util.attempt(times: 3, intervals: 0){ i += 1; raise Errno::ECONNREFUSED }
				end
				assert_equal 3, i
			end

			def test_attempt_raises_error_after_max_wait_http_fatal_error
				i = 0
				assert_raises(Net::HTTPFatalError) do
					Util.attempt(intervals: 1, max_wait: 2){ i += 2; raise Net::HTTPFatalError.new('a', 'b') }
				end
				assert_equal 6, i
			end

			def test_attempt_will_not_sleep_longer_than_max_wait
				start = Time.now
				assert_raises(Net::HTTPFatalError) do
					Util.attempt(intervals: [1, 5], max_wait: 2){ raise Net::HTTPFatalError.new('a', 'b') }
				end
				assert_in_delta 2, Time.now - start, 0.01
			end

			def test_attempt_return_block_result_when_success_given
				i = 0
				assert_equal 6, Util.attempt(intervals: 0, success: 6){ i += 2 }
				assert_equal 6, i
				assert_equal [], Util.attempt(times: 5, intervals: 0, success: []){ Array.new(i -= 2) }
				assert_equal 0, i
			end
		end
	end
end
