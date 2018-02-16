# frozen_string_literal: true

require 'open-uri'

require_relative 'test_helper'

module Jenkins2
	module IntegrationTest
		class ApiPluginsTest < Minitest::Test
			TEST_PLUGIN = 'mailer'

			def teardown
				@@subj.plugins.plugin(TEST_PLUGIN).uninstall rescue nil
				@@subj.plugins.plugin('emotional-jenkins-plugin').uninstall rescue nil
			end

			def test_plugin_fail_not_found
				exc = assert_raises Jenkins2::NotFoundError do
					@@subj.plugins.plugin('blueocean', depth: 1).subject
				end
				assert_equal 'Problem accessing /pluginManager/plugin/blueocean/api/json.', exc.message
			end

			def test_install_list_get_uninstall
				refute_includes @@subj.plugins(depth: 1).plugins.collect(&:shortName), TEST_PLUGIN
				assert_equal true, @@subj.plugins.install(TEST_PLUGIN)
				Jenkins2::Util.wait(max_wait_minutes: 1) do
					@@subj.plugins.plugin(TEST_PLUGIN).active?
				end
				assert_includes @@subj.plugins(depth: 1).plugins.collect(&:shortName), TEST_PLUGIN
				assert_equal 'Jenkins Mailer Plugin', @@subj.plugins.plugin(TEST_PLUGIN).longName
				assert_equal true, @@subj.plugins.plugin(TEST_PLUGIN).active?
				assert_equal false, @@subj.plugins.plugin(TEST_PLUGIN).deleted
				assert_equal true, @@subj.plugins.plugin(TEST_PLUGIN).uninstall
				assert_equal true, @@subj.plugins.plugin(TEST_PLUGIN).deleted
			end

			def test_upload
				open('http://mirrors.jenkins-ci.org/plugins/emotional-jenkins-plugin/1.1/'\
					'emotional-jenkins-plugin.hpi', 'rb') do |f|
					assert_equal true, @@subj.plugins.upload(f.read, 'emotional-jenkins-plugin.hpi')
				end
				Jenkins2::Util.wait do
					@@subj.plugins.plugin('emotional-jenkins-plugin').active?
				end
				assert_equal true, @@subj.plugins.plugin('emotional-jenkins-plugin').active?
				assert_equal '1.1', @@subj.plugins.plugin('emotional-jenkins-plugin').version
			end
		end
	end
end
