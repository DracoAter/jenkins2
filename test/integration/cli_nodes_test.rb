# frozen_string_literal: true

require_relative 'test_helper'

module Jenkins2
	module IntegrationTest
		class CliNodesTest < Minitest::Test
			CONFIG_XML = '<?xml version="1.0" encoding="UTF-8"?>
<slave>
  <name>%<name>s</name>
  <numExecutors>2</numExecutors>
  <mode>NORMAL</mode>
  <label></label>
  <nodeProperties/>
</slave>'

			CONFIG_XML_AFTER = '<?xml version="1.0" encoding="UTF-8"?>
<slave>
  <name>cli xml config</name>
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
  <name>cli xml config</name>
  <numExecutors>3</numExecutors>
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

			LOCALHOST_CONFIG_XML = '<?xml version="1.0" encoding="UTF-8"?>
<slave>
  <name>cli localhost</name>
  <remoteFS>/tmp/cli_localhost</remoteFS>
  <numExecutors>3</numExecutors>
  <mode>NORMAL</mode>
  <launcher class="hudson.slaves.CommandLauncher">
    <agentCommand>java -jar /tmp/slave.jar</agentCommand>
  </launcher>
  <label></label>
  <nodeProperties/>
</slave>'

			PLUGINS = %w[command-launcher].freeze
			@@subj.plugins.install PLUGINS
			Jenkins2::Util.wait do
				@@subj.plugins(depth: 1).plugins.select{|p| PLUGINS.include? p.shortName }.all?(&:active)
			end

			def setup
				@@subj.computer('cli xml config').create
				@@subj.computer('cli localhost').create
				@@subj.computer('cli for deletion').create
			end

			def teardown
				@@subj.computer('cli for deletion').delete rescue nil
				@@subj.computer('cli new one').delete rescue nil
				@@subj.computer('cli xml config').delete
				@@subj.computer('cli localhost').delete
			end

			def test_create_node
				refute_includes @@subj.computer.computer.collect(&:displayName), 'cli new one'
				$stdin, w = IO.pipe
				w.write(format(CONFIG_XML, name: 'cli new one'))
				w.close
				assert_equal true, Jenkins2::CLI::CreateNode.new(@@opts).parse(['-n', 'cli new one']).call
				assert_includes @@subj.computer.computer.collect(&:displayName), 'cli new one'
			end

			def test_delete
				assert_includes @@subj.computer.computer.collect(&:displayName), 'cli for deletion'
				assert_equal true, Jenkins2::CLI::DeleteNode.new(@@opts).parse(['-n', 'cli for deletion']).call
				refute_includes @@subj.computer.computer.collect(&:displayName), 'cli for deletion'
			end

			def test_get_node
				assert_raises Jenkins2::BadRequestError do
					Jenkins2::CLI::GetNode.new(@@opts).parse(['-n', '(master)']).call
				end
				assert_equal format(CONFIG_XML, name: 'cli xml config'), Jenkins2::CLI::GetNode.new(@@opts).
					parse(['-n', 'cli xml config']).call
			end

			def test_list_node
				assert_equal "master\ncli for deletion\ncli localhost\ncli xml config",
					Jenkins2::CLI::ListNode.new(@@opts).call
			end

			def test_list_online_node
				assert_equal 'master', Jenkins2::CLI::ListOnlineNode.new(@@opts).call
			end

			def test_update_node
				assert_equal format(CONFIG_XML, name: 'cli xml config'),
					@@subj.computer('cli xml config').config_xml
				$stdin, w = IO.pipe
				w.write(NEW_CONFIG_XML)
				w.close
				assert_equal true, Jenkins2::CLI::UpdateNode.new(@@opts).parse(['-n', 'cli xml config']).call
				assert_equal NEW_CONFIG_XML, @@subj.computer('cli xml config').config_xml
				$stdin, w = IO.pipe
				w.write(format(CONFIG_XML, name: 'cli xml config'))
				w.close
				assert_equal true, Jenkins2::CLI::UpdateNode.new(@@opts).parse(['-n', 'cli xml config']).call
				assert_equal format(CONFIG_XML, name: 'cli xml config'),
					@@subj.computer('cli xml config').config_xml
			end

			def test_toggle_offline
				assert_equal true, @@subj.computer('(master)').online?
				assert_equal true, Jenkins2::CLI::OfflineNode.new(@@opts).parse(
					['-n', '(master)', '-m', 'test message']
				).call
				assert_equal 'test message', @@subj.computer('(master)').offlineCauseReason
				assert_equal true, @@subj.computer('(master)').temporarilyOffline
				assert_equal true, Jenkins2::CLI::OnlineNode.new(@@opts).parse(['-n', '(master)']).call
				assert_equal false, @@subj.computer('(master)').temporarilyOffline
			ensure
				Jenkins2::CLI::OnlineNode.new(@@opts).parse(['-n', '(master)']).call
			end

			def test_connect_node_wait_node_online_disconnect_node_wait_node_offline
				assert_equal true, @@subj.computer('cli localhost').update(LOCALHOST_CONFIG_XML)
				assert_equal true, Jenkins2::CLI::ConnectNode.new(@@opts).parse(['-n', 'cli localhost']).call
				assert_equal true, Jenkins2::CLI::WaitNodeOnline.new(@@opts).parse(
					['-n', 'cli localhost', '-w', '2']
				).call

				assert_equal true, @@subj.computer('cli localhost').online?
				assert_equal true, Jenkins2::CLI::DisconnectNode.new(@@opts).parse(
					['-n', 'cli localhost', '-m', 'disconnected in cli test']
				).call
				assert_equal true, Jenkins2::CLI::WaitNodeOffline.new(@@opts).parse(
					['-n', 'cli localhost', '-w', '2']
				).call
				assert_equal false, @@subj.computer('cli localhost').online?
				assert_equal 'disconnected in cli test', @@subj.computer('cli localhost').
					offlineCauseReason
			end
		end
	end
end
