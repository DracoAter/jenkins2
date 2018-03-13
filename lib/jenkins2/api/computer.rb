# frozen_string_literal: true

require_relative 'rud'

module Jenkins2
	class API
		# Allows managing slaves (aka nodes, computers).
		module Computer
			# Step into proxy for managing slaves.
			# ==== Parameters:
			# +id+:: Slave id
			# +params+:: Key-value parameters. They will be added as URL parameters to request.
			# ==== Returns:
			# A Jenkins2::API::Computer::Proxy object
			def computer(id=nil, **params)
				proxy = Proxy.new connection, 'computer', params
				proxy.id = id
				proxy
			end

			class Proxy < ::Jenkins2::ResourceProxy
				attr_accessor :id
				include ::Jenkins2::API::RUD

				# Create a new "Dumb slave"
				# ==== Returns:
				# True on success
				def create
					connection.post(::File.join(@path, 'doCreateItem'), nil, name: @id,
						type: 'hudson.slaves.DumbSlave', json: '{}').code == '302'
				end

				# Disconnect slave.
				# ==== Parameters:
				# +offline_message+:: Record the reason about why the slave is disconnected.
				# ==== Returns:
				# True on success
				def disconnect(offline_message=nil)
					connection.post(build_path('doDisconnect'), nil,
						offlineMessage: offline_message).code == '302'
				end

				# Reconnect slave.
				# ==== Returns:
				# True on success
				def launch_agent
					connection.post(build_path('launchSlaveAgent')).code == '302'
				end

				# Checks if slave is online, that is not offline or temporarily offline,
				# ==== Returns:
				# True if not offline and not temporarily offline. False othewise.
				def online?
					not (offline or temporarilyOffline)
				end

				# Toggles slave state offline/online.
				# ==== Parameters:
				# +offline_message+:: Record the reason about why the slave is set offline.
				# ==== Returns:
				# True if slave changed its state.
				def toggle_offline(offline_message=nil)
					connection.post(build_path('toggleOffline'), nil,
						offlineMessage: offline_message).code == '302'
				end
			end
		end
	end
end
