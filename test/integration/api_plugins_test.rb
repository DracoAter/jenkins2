require 'uri'
require 'mocha'
require_relative 'test_helper'

module Jenkins2
	module IntegrationTest
		class ApiPluginsTest < Minitest::Test
			PLUGINS = %w{mailer}
			@@subj.plugins.install PLUGINS
			Jenkins2::Util.wait do
				PLUGINS.all?{|plg| @@subj.plugins.plugin( plg ).active? }
			end

			def test_plugins
				assert_includes @@subj.plugins( depth: 1 ).plugins.collect(&:shortName), 'mailer'
			end

			def test_plugin_success
				assert_equal 'Jenkins Mailer Plugin', @@subj.plugins.plugin( 'mailer' ).longName
			end

			def test_plugin_fail_not_found
				exc = assert_raises Jenkins2::NotFoundError do
					@@subj.plugins.plugin( 'chucknorris', depth: 1 ).subject
				end
				assert_equal 'Problem accessing /pluginManager/plugin/chucknorris/api/json.', exc.message
			end

			def test_install
				assert_equal true, @@subj.plugins.install( 'junit' )
				Jenkins2::Util.wait do
					@@subj.plugins.plugin( 'junit' ).active?
				end
				assert_equal true, @@subj.plugins.plugin( 'junit' ).active?
			end

			def test_uninstall
				assert_equal false, @@subj.plugins.plugin( 'mailer' ).deleted
				assert_equal true, @@subj.plugins.plugin( 'mailer' ).uninstall
				assert_equal true, @@subj.plugins.plugin( 'mailer' ).deleted
			end

			def test_upload
				skip 'Implement the test, with some small dummy plugin file'
			end
		end
	end
end
