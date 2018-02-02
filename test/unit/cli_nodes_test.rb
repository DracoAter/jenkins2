# frozen_string_literal: true

require_relative 'test_helper'

module Jenkins2
	module UnitTest
		class CliNodesTest < Minitest::Test
			def test_connect_node_summary
				assert_equal Jenkins2::UnitTest::CLITest::GLOBAL_SUMMARY +
					%(Command:
    connect-node                     Reconnect node(s).
Mandatory arguments:
    -n, --name X,Y,..                Slave name, or "(master)" for master, comma-separated \
list is supported.
), Jenkins2::CLI::ConnectNode.new.send(:summary)
			end

			def test_create_node_summary
				assert_equal Jenkins2::UnitTest::CLITest::GLOBAL_SUMMARY +
					%(Command:
    create-node                      Creates a new node by reading stdin for an XML configuration.
Mandatory arguments:
    -n, --name NAME                  Name of the node.
), Jenkins2::CLI::CreateNode.new.send(:summary)
			end

			def test_delete_node_summary
				assert_equal Jenkins2::UnitTest::CLITest::GLOBAL_SUMMARY +
					%(Command:
    delete-node                      Deletes node(s).
Mandatory arguments:
    -n, --name X,Y,..                Names of nodes to delete.
), Jenkins2::CLI::DeleteNode.new.send(:summary)
			end

			def test_disconnect_node_summary
				assert_equal Jenkins2::UnitTest::CLITest::GLOBAL_SUMMARY +
					%(Command:
    disconnect-node                  Disconnects node(s).
Mandatory arguments:
    -n, --name X,Y,..                Slave name, or "(master)" for master, comma-separated \
list is supported.
Optional arguments:
    -m, --message TEXT               Record the reason about why you are disconnecting the node(s).
), Jenkins2::CLI::DisconnectNode.new.send(:summary)
			end

			def test_get_node_summary
				assert_equal Jenkins2::UnitTest::CLITest::GLOBAL_SUMMARY +
					%(Command:
    get-node                         Dumps the node definition XML to stdout.
Mandatory arguments:
    -n, --name NAME                  Name of the node.
), Jenkins2::CLI::GetNode.new.send(:summary)
			end

			def test_list_node_summary
				assert_equal Jenkins2::UnitTest::CLITest::GLOBAL_SUMMARY +
					%(Command:
    list-node                        Outputs the node list.
), Jenkins2::CLI::ListNode.new.send(:summary)
			end

			def test_list_online_node_summary
				assert_equal Jenkins2::UnitTest::CLITest::GLOBAL_SUMMARY +
					%(Command:
    list-online-node                 Outputs the online node list.
), Jenkins2::CLI::ListOnlineNode.new.send(:summary)
			end

			def test_offline_node_summary
				assert_equal Jenkins2::UnitTest::CLITest::GLOBAL_SUMMARY +
					%(Command:
    offline-node                     Stop using a node for performing builds temporarily, until \
the next "online-node" command.
Mandatory arguments:
    -n, --name NAME                  Name of the node or "(master)" for master.
Optional arguments:
    -m, --message TEXT               Record the reason about why you are disconnecting the node.
), Jenkins2::CLI::OfflineNode.new.send(:summary)
			end

			def test_online_node_summary
				assert_equal Jenkins2::UnitTest::CLITest::GLOBAL_SUMMARY +
					%(Command:
    online-node                      Resume using a node for performing builds, to cancel out the \
earlier "offline-node" command.
Mandatory arguments:
    -n, --name NAME                  Name of the node or "(master)" for master.
), Jenkins2::CLI::OnlineNode.new.send(:summary)
			end

			def test_update_node_summary
				assert_equal Jenkins2::UnitTest::CLITest::GLOBAL_SUMMARY +
					%(Command:
    update-node                      Updates the node definition XML from stdin. The opposite of \
the get-node command.
Mandatory arguments:
    -n, --name NAME                  Name of the node.
), Jenkins2::CLI::UpdateNode.new.send(:summary)
			end

			def test_wait_node_offline_summary
				assert_equal Jenkins2::UnitTest::CLITest::GLOBAL_SUMMARY +
					%(Command:
    wait-node-offline                Wait for a node to become offline.
Mandatory arguments:
    -n, --name NAME                  Name of the node.
Optional arguments:
    -w, --wait MINUTES               Maximum number of minutes to wait. Default is 60.
), Jenkins2::CLI::WaitNodeOffline.new.send(:summary)
			end

			def test_wait_node_online_summary
				assert_equal Jenkins2::UnitTest::CLITest::GLOBAL_SUMMARY +
					%(Command:
    wait-node-online                 Wait for a node to become online.
Mandatory arguments:
    -n, --name NAME                  Name of the node.
Optional arguments:
    -w, --wait MINUTES               Maximum number of minutes to wait. Default is 60.
), Jenkins2::CLI::WaitNodeOnline.new.send(:summary)
			end
		end
	end
end
