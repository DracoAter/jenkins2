require 'open-uri'

require_relative 'test_helper'

module Jenkins2
	module IntegrationTest
		class ApiPluginsTest < Minitest::Test
			PLUGINS = %w{mailer label-verifier}
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
					@@subj.plugins.plugin( 'blueocean', depth: 1 ).subject
				end
				assert_equal 'Problem accessing /pluginManager/plugin/blueocean/api/json.', exc.message
			end

			def test_install
				assert_equal true, @@subj.plugins.install( 'junit' )
				Jenkins2::Util.wait( max_wait_minutes: 1 ) do
					@@subj.plugins.plugin( 'junit' ).active?
				end
				assert_equal true, @@subj.plugins.plugin( 'junit' ).active?
			end

			def test_uninstall
				assert_equal false, @@subj.plugins.plugin( 'label-verifier' ).deleted
				assert_equal true, @@subj.plugins.plugin( 'label-verifier' ).uninstall
				assert_equal true, @@subj.plugins.plugin( 'label-verifier' ).deleted
			end

			def test_upload
				open( 'http://mirrors.jenkins-ci.org/plugins/emotional-jenkins-plugin/1.1/emotional-jenkins-plugin.hpi', 'rb' ) do |f|
					assert_equal true, @@subj.plugins.upload( f.read, 'emotional-jenkins-plugin.hpi' )
				end
				Jenkins2::Util.wait do
					@@subj.plugins.plugin( 'emotional-jenkins-plugin' ).active?
				end
				assert_equal true, @@subj.plugins.plugin( 'emotional-jenkins-plugin' ).active?
				assert_equal '1.1', @@subj.plugins.plugin( 'emotional-jenkins-plugin' ).version
			end
		end
	end
end
