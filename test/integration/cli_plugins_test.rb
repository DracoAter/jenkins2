# frozen_string_literal: true

require_relative 'test_helper'

module Jenkins2
	module IntegrationTest
		class CliPluginsTest < Minitest::Test
			TEST_PLUGIN = 'label-verifier'

			def teardown
				@@subj.plugins.plugin(TEST_PLUGIN).uninstall rescue nil
				@@subj.plugins.plugin('chucknorris').uninstall rescue nil
			end

			def test_show_plugin_not_found
				exc = assert_raises Jenkins2::NotFoundError do
					Jenkins2::CLI::ShowPlugin.new(@@opts).parse(['-n', 'blueocean']).call
				end
				assert_equal 'Problem accessing /pluginManager/plugin/blueocean/api/json.', exc.message
			end

			def test_install_by_short_name_list_show_unistall
				refute_includes Jenkins2::CLI::ListPlugins.new(@@opts).call, TEST_PLUGIN
				assert_equal true, Jenkins2::CLI::InstallPlugin.new(@@opts).parse(['-n', TEST_PLUGIN]).call
				Jenkins2::Util.attempt(max_wait: 60, success: true) do
					@@subj.plugins.plugin(TEST_PLUGIN).active?
				end
				assert_includes Jenkins2::CLI::ListPlugins.new(@@opts).call, TEST_PLUGIN
				assert_equal 'label-verifier (1.2) - Jenkins Label Verifier plugin',
					Jenkins2::CLI::ShowPlugin.new(@@opts).parse(['-n', TEST_PLUGIN]).call
				assert_equal true, Jenkins2::CLI::UninstallPlugin.new(@@opts).parse(
					['-n', TEST_PLUGIN]
				).call
				assert_equal true, @@subj.plugins.plugin(TEST_PLUGIN).deleted
			end

			def test_install_by_source
				assert_equal true, Jenkins2::CLI::InstallPlugin.new(@@opts).parse(
					['-s', 'http://mirrors.jenkins-ci.org/plugins/chucknorris/0.9/chucknorris.hpi']
				).call
				Jenkins2::Util.attempt(max_wait: 60, success: true) do
					@@subj.plugins.plugin('chucknorris').active?
				end
				assert_equal true, @@subj.plugins.plugin('chucknorris').active?
				assert_equal '0.9', @@subj.plugins.plugin('chucknorris').version
			end
		end
	end
end
