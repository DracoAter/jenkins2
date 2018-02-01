# frozen_string_literal: true

require_relative 'test_helper'

module Jenkins2
	module UnitTest
		class LogTest < Minitest::Test
			def teardown
				$stderr = STDERR
				Log.init(log: $stderr, verbose: -1)
			end

			def test_log_message_format_stderr
				r, $stderr = IO.pipe
				Log.init(verbose: 3)
				$stderr.stub :tty?, true do
					Log.info 'as is'
				end
				assert_equal "as is\n", r.gets
			end

			def test_log_message_format_io
				r, w = IO.pipe
				Log.init(log: w, verbose: 3)
				Log.info 'some message'
				assert_equal "[#{Time.now.strftime '%FT%T%:z'}] INFO some message\n", r.gets
			end
		end
	end
end
