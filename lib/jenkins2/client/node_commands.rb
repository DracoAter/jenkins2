module Jenkins2
	class Client
		module NodeCommands
			# Connects a node.
			# +node+:: Node name, <tt>(master)</tt> for master.
			def connect_node( node: '(master)' )
				api_request( :post, "/computer/#{node}/launchSlaveAgent" )
			end

			# Creates a new node, by providing node definition XML.
			# Keyword parameters:
			# +node+:: Node name.
			# +xml_config+:: New configuration in xml format.
			def create_node( node: nil, xml_config: nil )
				xml_config = STDIN.read if xml_config.nil?
				api_request( :post, "/computer/doCreateItem", :raw ) do |req|
					req.form_data = { 'name' => node, type: "hudson.slaves.DumbSlave$DescriptorImpl",
						json: {}.to_json }
				end
				update_node( node: node, xml_config: xml_config )
			end
			
			# Deletes a node
			# +node+:: Node name. Master cannot be deleted.
			def delete_node( node )
				api_request( :post, "/computer/#{node}/doDelete" )
			end

			# Disconnects a node.
			# +node+:: Node name, <tt>(master)</tt> for master.
			# +message+:: Reason why the node is being disconnected.
			def disconnect_node( node: '(master)', message: nil )
				api_request( :post, "/computer/#{node}/doDisconnect" ) do |req|
					req.body = "offlineMessage=#{CGI::escape message}" unless message.nil?
				end
			end

			# Returns the node definition XML.
			# +node+:: Node name, <tt>(master)</tt> for master.
			def get_node_xml( node: '(master)' )
				api_request( :get, "/computer/#{node}/config.xml", :body )
			end
			
			# Returns the node state
			# +node+:: Node name, <tt>(master)</tt> for master.
			def get_node( node: '(master)' )
				api_request( :get, "/computer/#{node}/api/json" )
			end

			# Sets node temporarily offline. Does nothing, if node is already offline.
			# +node+:: Node name, or <tt>(master)</tt> for master.
			# +message+:: Record the note about this node is being disconnected.
			def offline_node( node: '(master)', message: nil )
				if node_online?( node )
					api_request( :post, "/computer/#{node}/toggleOffline" ) do |req|
						req.body = "offlineMessage=#{CGI::escape message}" unless message.nil?
					end
				end
			end

			# Sets node back online, if node is temporarily offline.
			# +node+:: Node name, <tt>(master)</tt> for master.
			def online_node( node: '(master)' )
				api_request( :post, "/computer/#{node}/toggleOffline" ) unless node_online?( node )
			end

			# Updates the node definition XML
			# Keyword parameters:
			# +node+:: Node name, <tt>(master)</tt> for master.
			# +xml_config+:: New configuration in xml format.
			def update_node( node: '(master)', xml_config: nil )
				xml_config = STDIN.read if xml_config.nil?
				api_request( :post, "/computer/#{node}/config.xml", :body ) do |req|
					req.body = xml_config
				end
			end

			# Waits for node to become idle or until +max_wait_minutes+ pass.
			# +node+:: Node name, <tt>(master)</tt> for master.
			# +max_wait_minutes+:: Maximum wait time in minutes. Default 60.
			def wait_node_idle( node: '(master)', max_wait_minutes: 60 )
				Jenkins2::Wait.wait( max_wait_minutes: max_wait_minutes ){ node_idle? node }
			end

			def node_idle?( node: '(master)' )
				get_node( node: node )['idle']
			end

			# Checks if node is online (= not temporarily offline )
			# +node+:: Node name. Use <tt>(master)</tt> for master.
			def node_online?( node )
				!get_node( node: node )['temporarilyOffline']
			end

			# Checks if node is connected, i.e. Master connected and launched client on it.
			# +node+:: Node name. Use <tt>(master)</tt> for master.
			def node_connected?( node )
				!get_node( node: node )['offline']
			end
		end
	end
end
