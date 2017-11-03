module Jenkins2
	module API
		module Job
			def job( id, **params )
				path = build_path 'job', id
				Proxy.new connection, path, params
			end

			class Proxy < ::Jenkins2::ResourceProxy
				def config_xml( config_xml=nil )
					path = build_path 'config.xml'
					if config_xml.nil?
						connection.get path
					else
						connection.post path, config_xml
					end
				end

				def delete
					path = build_path 'doDelete'
					connection.post path
				end

				def disable
					connection.post build_path 'disable'
				end

				def enable
					connection.post build_path 'enable'
				end
			end
		end
	end
end
