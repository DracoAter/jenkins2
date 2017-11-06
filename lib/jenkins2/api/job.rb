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

				def copy( from )
					connection.post( 'createItem', nil, name: id, from: from, mode: 'copy' ).code == '302'
				end

				def update( config_xml )
					connection.post( build_path( 'config.xml' ), config_xml ).code == '200'
				end

				def config_xml
					connection.get( build_path 'config.xml' ).body
				end

				def delete
					connection.post( build_path 'doDelete' ).code == '302'
				end

				def disable
					connection.post( build_path 'disable' ).code == '302'
				end

				def enable
					connection.post( build_path 'enable' ).code == '302'
				end

				def build( build_parameters={} )
					if build_parameters.empty?
						connection.post( build_path 'build' )
					else
						connection.post( build_path( 'buildWithParameters' ), nil, build_parameters )
					end.code == '201'
				end
			
				def polling
					connection.post( build_path 'polling' )
				end
			end
		end
	end
end
