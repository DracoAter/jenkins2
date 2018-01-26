require_relative 'rud'

module Jenkins2
	class API
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
				include ::Jenkins2::RUD

				def create( config_xml )
					connection.post( 'createView', config_xml, name: id ) do |req|
						req['Content-Type'] = 'text/xml'
					end.code == '200'
				end

				def add_job( job_name )
					connection.post( build_path( 'addJobToView' ), nil, name: job_name ).code == '200'
				end

				def remove_job( job_name )
					connection.post( build_path( 'removeJobFromView' ), nil, name: job_name ).code == '200'
				end
			end
		end
	end
end
