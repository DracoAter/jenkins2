require_relative 'test_helper'

module Jenkins2
	module IntegrationTest
		class ApiRootTest < Minitest::Test
			def teardown
				Jenkins2::Util.wait( max_wait_minutes: 2 ){ @@subj.version }
				@@subj.cancel_quiet_down
			end

			def test_root
				assert_equal [:_class, :assignedLabels, :mode, :nodeDescription, :nodeName, :numExecutors,
					:description, :jobs, :overallLoad, :primaryView, :quietingDown, :slaveAgentPort,
					:unlabeledLoad, :useCrumbs, :useSecurity, :views], @@subj.root.to_h.keys
			end

			def test_version
				assert_equal '2.73.2', @@subj.version
			end

			def test_quiet_down
				assert_equal false, @@subj.root.quietingDown
				assert_equal true, @@subj.quiet_down
				assert_equal true, @@subj.root.quietingDown
				assert_equal true, @@subj.cancel_quiet_down
				assert_equal false, @@subj.root.quietingDown
			end

			def test_restart
				assert_equal true, @@subj.restart!
				assert_raises Jenkins2::ServiceUnavailableError do
					@@subj.version
				end
			end

			def test_safe_restart
				assert_equal true, @@subj.restart
				assert_raises Jenkins2::ServiceUnavailableError do
					@@subj.version
				end
			end
		end
	end
end
