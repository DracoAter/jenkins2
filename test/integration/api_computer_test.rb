require_relative 'test_helper'

module Jenkins2
	module IntegrationTest
		class ApiComputerTest < Minitest::Test
			CONFIG_XML = '<?xml version="1.0" encoding="UTF-8"?>
<slave>
  <name>xml config</name>
  <numExecutors>2</numExecutors>
  <mode>NORMAL</mode>
  <label></label>
  <nodeProperties/>
</slave>'

			CONFIG_XML_AFTER = '<?xml version="1.0" encoding="UTF-8"?>
<slave>
  <name>xml config</name>
  <numExecutors>2</numExecutors>
  <mode>NORMAL</mode>
  <launcher class="hudson.slaves.JNLPLauncher">
    <workDirSettings>
      <disabled>true</disabled>
      <internalDir>remoting</internalDir>
      <failIfWorkDirIsMissing>false</failIfWorkDirIsMissing>
    </workDirSettings>
  </launcher>
  <label></label>
  <nodeProperties/>
</slave>'

			NEW_CONFIG_XML = '<?xml version="1.0" encoding="UTF-8"?>
<slave>
  <name>xml config</name>
  <numExecutors>3</numExecutors>
  <mode>NORMAL</mode>
  <launcher class="hudson.slaves.CommandLauncher" plugin="command-launcher@1.2">
    <agentCommand>java -jar /tmp/slave.jar</agentCommand>
  </launcher>
  <label></label>
  <nodeProperties/>
</slave>'

			LOCALHOST_CONFIG_XML = '<?xml version="1.0" encoding="UTF-8"?>
<slave>
  <name>localhost</name>
  <remoteFS>/tmp/localhost</remoteFS>
  <numExecutors>3</numExecutors>
  <mode>NORMAL</mode>
  <launcher class="hudson.slaves.CommandLauncher">
    <agentCommand>java -jar /tmp/slave.jar</agentCommand>
  </launcher>
  <label></label>
  <nodeProperties/>
</slave>'

			PLUGINS = %w{command-launcher}
			@@subj.plugins.install PLUGINS
			Jenkins2::Util.wait do
				PLUGINS.all?{|plg| @@subj.plugins.plugin( plg ).active? }
			end

			def setup
				@@subj.computer( 'xml config' ).create
				@@subj.computer( 'localhost' ).create
				@@subj.computer( 'for deletion' ).create
			end

			def teardown
				@@subj.computer( 'xml config' ).delete
				@@subj.computer( 'localhost' ).delete
				@@subj.computer( 'for deletion' ).delete rescue nil
				@@subj.computer( 'new one' ).delete rescue nil
			end

			def test_computer
				assert_includes @@subj.computer.computer.collect(&:displayName), 'master'
			end

			def test_create
				refute_includes @@subj.computer.computer.collect(&:displayName), 'new one'
				assert_equal true, @@subj.computer( 'new one' ).create
				assert_includes @@subj.computer.computer.collect(&:displayName), 'new one'
			end

			def test_delete
				assert_includes @@subj.computer.computer.collect(&:displayName), 'for deletion'
				assert_equal true, @@subj.computer( 'for deletion' ).delete
				refute_includes @@subj.computer.computer.collect(&:displayName), 'for deletion'
			end
			
			def test_get_config_xml
				assert_raises Jenkins2::BadRequestError do
					@@subj.computer('(master)').config_xml
				end
				assert_equal CONFIG_XML, @@subj.computer('xml config').config_xml
			end

			def test_update
				assert_equal CONFIG_XML, @@subj.computer('xml config').config_xml
				assert_equal true, @@subj.computer('xml config').update( NEW_CONFIG_XML )
				assert_equal NEW_CONFIG_XML, @@subj.computer('xml config').config_xml
				assert_equal true, @@subj.computer('xml config').update( CONFIG_XML )
				assert_equal CONFIG_XML, @@subj.computer('xml config').config_xml
			end

			def test_idle
				assert_equal true, @@subj.computer( '(master)' ).idle
			end

			def test_toggle_offline
				assert_equal true, @@subj.computer( '(master)' ).online?
				assert_equal false, @@subj.computer( '(master)' ).temporarilyOffline
				assert_equal true, @@subj.computer( '(master)' ).toggle_offline( 'test message' )
				assert_equal 'test message', @@subj.computer( '(master)' ).offlineCauseReason
				assert_equal true, @@subj.computer( '(master)' ).temporarilyOffline
				assert_equal false, @@subj.computer( '(master)' ).online?
				assert_equal true, @@subj.computer( '(master)' ).toggle_offline( 'test message' )
				assert_equal false, @@subj.computer( '(master)' ).temporarilyOffline
			ensure
				@@subj.computer( '(master)' ).toggle_offline if @@subj.computer( '(master)' ).temporarilyOffline
			end

			def test_launch_agent_and_disconnect
				assert_equal true, @@subj.computer( 'localhost' ).update( LOCALHOST_CONFIG_XML )
				assert_equal true, @@subj.computer( 'localhost' ).launch_agent
				Jenkins2::Util.wait( max_wait_minutes: 2 ) do
					@@subj.computer( 'localhost' ).online?
				end
				assert_equal true, @@subj.computer( 'localhost' ).online?
				assert_equal true, @@subj.computer( 'localhost' ).disconnect( 'disconnected in test' )
				assert_equal false, @@subj.computer( 'localhost' ).online?
				assert_equal 'disconnected in test', @@subj.computer( 'localhost' ).offlineCauseReason
			end
		end
	end
end
