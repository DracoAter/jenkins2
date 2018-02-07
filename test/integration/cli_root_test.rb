# frozen_string_literal: true

require_relative 'test_helper'

module Jenkins2
	module IntegrationTest
		class CliRootTest < Minitest::Test
			def test_safe_restart
				assert_equal true, Jenkins2::CLI::SafeRestart.new(@@opts).call
				assert_raises Jenkins2::ServiceUnavailableError do
					@@subj.version
				end
				Jenkins2::Util.wait(max_wait_minutes: 2) do
					@@subj.version
				end
			end

			def test_restart
				assert_equal true, Jenkins2::CLI::Restart.new(@@opts).call
				assert_raises Jenkins2::ServiceUnavailableError do
					@@subj.version
				end
				Jenkins2::Util.wait(max_wait_minutes: 2) do
					@@subj.version
				end
			end

			def test_quiet_down_cancel_quiet_down
				assert_equal true, Jenkins2::CLI::QuietDown.new(@@opts).call
				assert_equal true, @@subj.root.quietingDown
				assert_equal true, Jenkins2::CLI::CancelQuietDown.new(@@opts).call
				assert_equal false, @@subj.root.quietingDown
			end

			def test_version
				assert_equal '2.89.3', Jenkins2::CLI::Version.new(@@opts).call
			end
		end
	end
end
