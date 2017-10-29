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
				assert_includes @@subj.plugins( depth: 1 )['plugins'].collect{|i| i['shortName']}, 'mailer'
			end

			def test_plugin_success
				assert_equal 'Jenkins Mailer Plugin', @@subj.plugins.plugin( 'mailer' )['longName']
			end

			def test_plugin_fail_not_found
				exc = assert_raises Net::HTTPServerException do
					@@subj.plugins.plugin( 'chucknorris', depth: 1 ).subject
				end
				assert_equal '404 "Not Found"', exc.message
			end

			def test_install
				assert_equal '302', @@subj.plugins.install( 'junit' ).code
				Jenkins2::Util.wait do
					@@subj.plugins.plugin( 'junit' ).active?
				end
				assert @@subj.plugins.plugin( 'junit' ).active?
			end

			def test_uninstall
				refute @@subj.plugins.plugin( 'mailer' )['deleted']
				assert_equal '302', @@subj.plugins.plugin( 'mailer' ).uninstall.code
				assert @@subj.plugins.plugin( 'mailer' )['deleted']
			end
		end
	end
end
