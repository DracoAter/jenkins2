require 'uri'
require 'mocha'
require_relative 'test_helper'

module Jenkins2
	module IntegrationTest
		class ApiPluginsTest < Minitest::Test
			@@subj = Jenkins2::Connection.new( @@server ).basic_auth @@user, @@key

			def test_plugins
				assert_equal [], @@subj.plugins( depth: 1 )['plugins'].collect{|i| i['shortName']}.sort
			end

			def test_plugin_success
				assert_equal '302', @@subj.plugins.install( 'mailer' ).code
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
				refute @@subj.plugins.plugin( 'junit' )['deleted']
			end

			def test_uninstall
				assert_equal '302', @@subj.plugins.install( 'mailer' ).code
				refute @@subj.plugins.plugin( 'mailer' )['deleted']
				assert_equal '302', @@subj.plugins.plugin( 'mailer' ).uninstall.code
				assert @@subj.plugins.plugin( 'mailer' )['deleted']
			end
		end
	end
end
