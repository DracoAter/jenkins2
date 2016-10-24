require 'uri'
require 'mocha'
require_relative 'test_helper'

module Jenkins2
	module IntegrationTest
		class ClientNodeTest < Minitest::Test
			def setup
				for_deletion = %Q{<?xml version="1.0" encoding="UTF-8"?>
<slave>
  <name>for deletion</name>
  <remoteFS>/home/jenkins</remoteFS>
  <numExecutors>3</numExecutors>
  <mode>EXCLUSIVE</mode>
  <retentionStrategy class="hudson.slaves.RetentionStrategy$Always"/>
  <label>64bit mac-os-x</label>
  <nodeProperties/>
</slave>}
				@@subj.create_node( node: 'for deletion', xml_config: for_deletion ) rescue nil
				another = %Q{<?xml version="1.0" encoding="UTF-8"?>
<slave>
  <name>another one</name>
  <remoteFS>/home/jenkins</remoteFS>
  <numExecutors>3</numExecutors>
  <mode>EXCLUSIVE</mode>
  <retentionStrategy class="hudson.slaves.RetentionStrategy$Always"/>
  <label>64bit mac-os-x</label>
  <nodeProperties/>
</slave>}
				@@subj.create_node( node: 'another one', xml_config: another ) rescue nil
				@@subj.connect_node node: 'another one'
				@@subj.online_node node: '(master)'
			end

			def teardown
				@@subj.delete_node 'test' rescue nil
				@@subj.delete_node 'for deletion' rescue nil
				@@subj.delete_node 'another one' rescue nil
			end

			def test_get_master_node
				node = @@subj.get_node
				assert_equal 2, node['numExecutors']
				refute node['offline']
				assert_nil node['offlineCause']
				assert_equal '', node['offlineCauseReason']
				refute node['temporarilyOffline']
				assert_equal 'master', node['displayName']
			end

			def test_connect_disconnect_node
				skip
				assert @@subj.node_connected?( 'another one' )
				@@subj.disconnect_node node: 'another one', message: 'in test_connect_disconnect_node'
				refure @@subj.node_connected?( 'another one' )
				@@subj.connect_node node: 'another one'
			end

			def test_create_node
				xml_config = %Q{<?xml version="1.0" encoding="UTF-8"?>
<slave>
  <name>test</name>
  <remoteFS>/home/jenkins</remoteFS>
  <numExecutors>4</numExecutors>
  <mode>EXCLUSIVE</mode>
  <retentionStrategy class="hudson.slaves.RetentionStrategy$Always"/>
  <launcher class="hudson.slaves.CommandLauncher">
    <agentCommand></agentCommand>
  </launcher>
  <label>64bit mac-os-x</label>
  <nodeProperties/>
</slave>}
				assert @@subj.create_node( node: 'test', xml_config: xml_config )
				assert_equal xml_config, @@subj.get_node_xml( node: 'test' )
			end

			def test_delete_node_argument_error_if_nil
				e = assert_raises ArgumentError do
					@@subj.delete_node
				end
				assert_equal 'node must be provided', e.message
			end

			def test_delete_node
				refute_nil @@subj.get_node( node: 'for deletion' )
				@@subj.delete_node node: 'for deletion'
				e = assert_raises Net::HTTPServerException do
					@@subj.get_node( node: 'for deletion' )
				end
				assert_equal '404', e.response.code
			end

			def test_idle_node
				assert @@subj.node_idle?
				assert @@subj.node_idle? node: '(master)'
				assert @@subj.wait_node_idle( max_wait_minutes: 1 )
			end

			def test_online_offline_node
				assert @@subj.node_online?( node: '(master)' )
				@@subj.offline_node node: '(master)', message: 'in test_online_offline_node'
				refute @@subj.node_online?( node: '(master)' )
				@@subj.online_node node: '(master)'
			end

			def test_node_connected
				assert @@subj.node_connected?
				assert @@subj.node_connected? node: '(master)'
				refute @@subj.node_connected? node: 'for deletion'
			end
		end
	end
end
