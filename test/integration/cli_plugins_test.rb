# frozen_string_literal: true

require_relative 'test_helper'

module Jenkins2
	module IntegrationTest
		class CliPluginsTest < Minitest::Test
			PLUGINS = %w[ant create-fingerprint].freeze
			@@subj.plugins.install PLUGINS
			Jenkins2::Util.wait do
				@@subj.plugins(depth: 1).plugins.select{|p| PLUGINS.include? p.shortName }.all?(&:active)
			end

			def test_list_plugins
				assert_includes Jenkins2::CLI::ListPlugins.new(@@opts).call, 'ant'
			end

			def test_show_plugin_success
				assert_equal 'ant (1.8) - Ant Plugin',
					Jenkins2::CLI::ShowPlugin.new(@@opts.merge(name: 'ant')).call
			end

			def test_show_plugin_not_found
				exc = assert_raises Jenkins2::NotFoundError do
					Jenkins2::CLI::ShowPlugin.new(@@opts.merge(name: 'blueocean')).call
				end
				assert_equal 'Problem accessing /pluginManager/plugin/blueocean/api/json.', exc.message
			end

			def test_install_by_short_name
				assert_equal true, Jenkins2::CLI::InstallPlugin.new(@@opts.merge(name: 'junit')).call
				Jenkins2::Util.wait(max_wait_minutes: 1) do
					@@subj.plugins.plugin('junit').active?
				end
				assert_equal true, @@subj.plugins.plugin('junit').active?
			end

			def test_install_by_source
				assert_equal true, Jenkins2::CLI::InstallPlugin.new(@@opts.merge(source:
					'http://mirrors.jenkins-ci.org/plugins/chucknorris/0.9/chucknorris.hpi',
					name: 'chucknorris.hpi')).call
				Jenkins2::Util.wait(max_wait_minutes: 1) do
					@@subj.plugins.plugin('chucknorris').active?
				end
				assert_equal true, @@subj.plugins.plugin('chucknorris').active?
				assert_equal '0.9', @@subj.plugins.plugin('chucknorris').version
			end

			def test_uninstall_plugin
				assert_equal false, @@subj.plugins.plugin('create-fingerprint').deleted
				assert_equal true, Jenkins2::CLI::UninstallPlugin.new(
					@@opts.merge(name: 'create-fingerprint')
				).call
				assert_equal true, @@subj.plugins.plugin('create-fingerprint').deleted
			end
		end
	end
end
