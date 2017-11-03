module Jenkins2
	module API
		module View
			MODE_LIST_VIEW = 'hudson.model.ListView'

			def view( id, **params )
				proxy = Proxy.new connection, 'view', params
				proxy.id = id
				proxy
			end

			def views( **params )
				::Jenkins2::ResourceProxy.new( connection, '', params ).views
			end

			class Proxy < ::Jenkins2::ResourceProxy
				attr_accessor :id

				def config_xml( config_xml=nil )
					path = build_path 'config.xml'
					if config_xml.nil?
						connection.get path
					else
						connection.post path, config_xml
					end
				end

				def create( config_xml )
					connection.post( 'createView', config_xml, name: id ) do |req|
						req['Content-Type'] = 'text/xml'
					end
				end

				def delete
					path = build_path 'doDelete'
					connection.post path
				end
			end
		end
	end
end
