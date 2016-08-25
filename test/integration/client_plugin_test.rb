require 'uri'
require 'mocha'
require_relative 'test_helper'

module Jenkins2
	class ClientPluginTest < Minitest::Test
		def test_plugin_installed_no_such_plugin
			refute @@subj.plugin_installed?( 'chucknorris' )
		end

		def test_install_plugins
			assert_equal "http://#{@@ip}:8080/updateCenter/", @@subj.install_plugins( 'junit' )
			assert @@subj.wait_plugins_installed 'junit'
			assert_includes @@subj.list_plugins, {"active"=>true, "backupVersion"=>nil, "bundled"=>false,
				"deleted"=>false, "dependencies"=>[{}], "downgradable"=>false, "enabled"=>true,
				"hasUpdate"=>false, "longName"=>"JUnit Plugin", "pinned"=>false, "shortName"=>"junit",
				"supportsDynamicLoad"=>"MAYBE",
				"url"=>"http://wiki.jenkins-ci.org/display/JENKINS/JUnit+Plugin", "version"=>"1.18"}
		end
		
		def test_uninstall_plugin
			assert_equal "http://#{@@ip}:8080/updateCenter/", @@subj.install_plugins( 'mailer' )
			assert @@subj.wait_plugins_installed 'mailer'
			assert_equal "http://#{@@ip}:8080/pluginManager/installed", @@subj.uninstall_plugin( 'mailer' )
			refute @@subj.plugin_installed?( 'mailer' )
			assert @@subj.list_plugins.detect{|i| i['shortName'] == 'mailer' }['deleted']
		end
	end
end
