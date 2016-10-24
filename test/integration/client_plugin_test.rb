require 'uri'
require 'mocha'
require_relative 'test_helper'

module Jenkins2
	module IntegrationTest
		class ClientPluginTest < Minitest::Test
			def test_plugins_installed_no_such_plugin
				refute @@subj.plugins_installed?( 'chucknorris' )
			end

			def test_install_plugins
				assert_equal "#{@@server}/updateCenter/", @@subj.install_plugins( 'junit' )
				assert @@subj.wait_plugins_installed 'junit'
				assert_includes @@subj.list_plugins, {"active"=>true, "backupVersion"=>nil, "bundled"=>false,
					"deleted"=>false, "dependencies"=>[{},{}], "downgradable"=>false, "enabled"=>true,
					"hasUpdate"=>false, "longName"=>"JUnit Plugin", "pinned"=>false, "requiredCoreVersion"=>"1.580.1",
					"shortName"=>"junit", "supportsDynamicLoad"=>"MAYBE",
					"url"=>"http://wiki.jenkins-ci.org/display/JENKINS/JUnit+Plugin", "version"=>"1.19"}
			end

			def test_uninstall_plugin
				assert_equal "#{@@server}/updateCenter/", @@subj.install_plugins( 'mailer' )
				assert @@subj.wait_plugins_installed 'mailer'
				assert_equal "#{@@server}/pluginManager/installed", @@subj.uninstall_plugin( 'mailer' )
				refute @@subj.plugins_installed?( 'mailer' )
				assert @@subj.list_plugins.detect{|i| i['shortName'] == 'mailer' }['deleted']
			end
		end
	end
end
