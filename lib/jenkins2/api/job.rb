module Jenkins2
	module API
		module Job
			def job( name, **params )
				proxy = Proxy.new connection, 'job', params
				proxy.id = name
				proxy
			end

			class Proxy < ::Jenkins2::ResourceProxy
				attr_accessor :id

				def create( config_xml )
					connection.post( 'createItem', config_xml, name: id ) do |req|
						req['Content-Type'] = 'text/xml'
					end.code == '200'
				end

				def update( config_xml )
					path = build_path 'config.xml'
					connection.post( path, config_xml ).code == '200'
				end

				def config_xml
					path = build_path 'config.xml'
					connection.get path
				end

				def delete
					path = build_path 'doDelete'
					connection.post path
				end

				def disable
					connection.post( build_path 'disable' ).code == '302'
				end

				def enable
					connection.post( build_path 'enable' ).code == '302'
				end
			end
		end
	end
end
