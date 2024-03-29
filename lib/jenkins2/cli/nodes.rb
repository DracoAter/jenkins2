# frozen_string_literal: true

module Jenkins2
	class CLI
		class ConnectNode < CLI
			def self.description
				'Reconnect node(s).'
			end

			def add_options
				parser.separator 'Mandatory arguments:'
				parser.on '-n', '--name X,Y,..', Array, 'Slave name, or "(master)" for master, '\
					'comma-separated list is supported.' do |n|
					options[:name] = n
				end
			end

			def run
				options[:name].all? do |name|
					jc.computer(name).launch_agent
				end
			end
		end

		class CreateNode < CLI
			def self.description
				'Create a new node by reading stdin for an XML configuration.'
			end

			def add_options
				parser.separator 'Mandatory arguments:'
				parser.on '-n', '--name NAME', 'Name of the node.' do |n|
					options[:name] = n
				end
			end

			def run
				jc.computer(options[:name]).create and
					jc.computer(options[:name]).update($stdin.read)
			end
		end

		class DeleteNode < CLI
			def self.description
				'Delete node(s).'
			end

			def add_options
				parser.separator 'Mandatory arguments:'
				parser.on '-n', '--name X,Y,..', Array, 'Names of nodes to delete.' do |n|
					options[:name] = n
				end
			end

			def run
				options[:name].all? do |name|
					jc.computer(name).delete
				end
			end
		end

		class DisconnectNode < CLI
			def self.description
				'Disconnect node(s).'
			end

			def add_options
				parser.separator 'Mandatory arguments:'
				parser.on '-n', '--name X,Y,..', Array, 'Slave name, or "(master)" for master, '\
					'comma-separated list is supported.' do |n|
					options[:name] = n
				end
				parser.separator 'Optional arguments:'
				parser.on '-m', '--message TEXT', 'Record the reason about why you are disconnecting the'\
					' node(s).' do |m|
					options[:message] = m
				end
			end

			def run
				options[:name].all? do |name|
					jc.computer(name).disconnect(options[:message])
				end
			end
		end

		class GetNode < CLI
			def self.description
				'Dump the node definition XML to stdout.'
			end

			def add_options
				parser.separator 'Mandatory arguments:'
				parser.on '-n', '--name NAME', 'Name of the node.' do |n|
					options[:name] = n
				end
			end

			def run
				jc.computer(options[:name]).config_xml
			end
		end

		class ListNode < CLI
			def self.description
				'Output the node list.'
			end

			def run
				jc.computer.computer.collect(&:displayName).join("\n")
			end
		end

		class ListOnlineNode < CLI
			def self.description
				'Output the online node list.'
			end

			def run
				jc.computer.computer.delete_if{|i| i.offline or i.temporarilyOffline }.
					collect(&:displayName).join("\n")
			end
		end

		class OfflineNode < CLI
			def self.description
				'Stop using a node for performing builds temporarily, until the next "online-node" '\
				'command.'
			end

			def add_options
				parser.separator 'Mandatory arguments:'
				parser.on '-n', '--name NAME', 'Name of the node or "(master)" for master.' do |n|
					options[:name] = n
				end
				parser.separator 'Optional arguments:'
				parser.on '-m', '--message TEXT', 'Record the reason about why you are disconnecting the'\
					' node.' do |m|
					options[:message] = m
				end
			end

			def run
				return if jc.computer(options[:name]).temporarilyOffline
				jc.computer(options[:name]).toggle_offline(options[:message])
			end
		end

		class OnlineNode < CLI
			def self.description
				'Resume using a node for performing builds, to cancel out the earlier "offline-node" '\
				'command.'
			end

			def add_options
				parser.separator 'Mandatory arguments:'
				parser.on '-n', '--name NAME', 'Name of the node or "(master)" for master.' do |n|
					options[:name] = n
				end
			end

			def run
				return unless jc.computer(options[:name]).temporarilyOffline
				jc.computer(options[:name]).toggle_offline
			end
		end

		class UpdateNode < CLI
			def self.description
				'Update the node definition XML from stdin. The opposite of the get-node command.'
			end

			def add_options
				parser.separator 'Mandatory arguments:'
				parser.on '-n', '--name NAME', 'Name of the node.' do |n|
					options[:name] = n
				end
			end

			def run
				jc.computer(options[:name]).update($stdin.read)
			end
		end

		class WaitNodeOffline < CLI
			def self.description
				'Wait for a node to become offline.'
			end

			def add_options
				parser.separator 'Mandatory arguments:'
				parser.on '-n', '--name NAME', 'Name of the node.' do |n|
					options[:name] = n
				end
				parser.separator 'Optional arguments:'
				parser.on '-w', '--wait MINUTES', Integer, 'Maximum number of minutes to wait. Default is '\
					'60.' do |w|
					options[:wait] = w
				end
			end

			def run
				Jenkins2::Util.attempt(max_wait: 60 * options[:wait], success: true) do
					!jc.computer(options[:name]).online?
				end
			end
		end

		class WaitNodeOnline < CLI
			def self.description
				'Wait for a node to become online.'
			end

			def add_options
				parser.separator 'Mandatory arguments:'
				parser.on '-n', '--name NAME', 'Name of the node.' do |n|
					options[:name] = n
				end
				parser.separator 'Optional arguments:'
				parser.on '-w', '--wait MINUTES', Integer, 'Maximum number of minutes to wait. Default is '\
					'60.' do |w|
					options[:wait] = w
				end
			end

			def run
				Jenkins2::Util.attempt(max_wait: 60 * options[:wait], success: true) do
					jc.computer(options[:name]).online?
				end
			end
		end
	end
end
