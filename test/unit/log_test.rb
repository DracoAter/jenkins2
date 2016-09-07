require 'uri'
require 'mocha'
require_relative 'test_helper'

module Jenkins2
	module UnitTest
		class LogTest < Minitest::Test
			def setup
				Jenkins2::Log.init( log: STDOUT, verbose: 3 )
			end

			def teardown
				Jenkins2::Log.init( log: STDOUT, verbose: -1 )
			end

			def test_log_calls_ruby_logger
				out, err = capture_subprocess_io do
					Log.info 'test'
					Log.info{ 'test' }
				end
				assert_equal "test\ntest\n", out

				out, err = capture_subprocess_io do
					Log.debug 'test2'
					Log.debug{ 'test2' }
				end
				assert_equal "test2\ntest2\n", out
			end

			def test_log_message_format_stdout
				out, _ = capture_subprocess_io do
					Log.info 'as is'
					Log.info { 'as is' }
				end
				assert_equal "as is\nas is\n", out
			end

			def test_log_message_format_io
				r, w = IO.pipe
				Jenkins2::Log.init( log: w, verbose: 3 )
				Log.info 'some message'
				assert_equal "[#{Time.now.strftime "%FT%T%:z"}] INFO some message\n", r.gets
			end
		end
	end
end
