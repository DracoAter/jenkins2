module Jenkins2
	module API
		module Computer
			def computer( id=nil, **params )
				proxy = Proxy.new connection, 'computer', params
				proxy.id = id
				proxy
			end

			class Proxy < ::Jenkins2::ResourceProxy
				attr_accessor :id

				def launch_agent
					path = build_path 'launchSlaveAgent'
					connection.post path
				end

				def create
					form_data = { name: @id, type: 'hudson.slaves.DumbSlave$DescriptorImpl', json: '{}' }
					@id = nil
					path = build_path 'doCreateItem'
					connection.post path, ::URI.encode_www_form( form_data )
				end

				def delete
					path = build_path 'doDelete'
					connection.post path
				end

				def disconnect( offline_message=nil )
					path = build_path 'doDisconnect'
					body = "offlineMessage=#{CGI.escape offline_message}" unless offline_message.nil?
					connection.post path, body
				end

				def config_xml( config_xml=nil )
					path = build_path 'config.xml'
					if config_xml
						connection.post( path, config_xml )
					else
						connection.get( path )
					end
				end

				def toggle_offline( offline_message=nil )
					path = build_path 'toggleOffline'
					body = "offlineMessage=#{CGI.escape offline_message}" unless offline_message.nil?
					connection.post path, body
				end
			end
		end
	end
end
