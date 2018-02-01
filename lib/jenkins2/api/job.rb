# frozen_string_literal: true

require_relative 'rud'

module Jenkins2
	class API
		module Job
			def job(name, **params)
				proxy = Proxy.new connection, 'job', params
				proxy.id = name
				proxy
			end

			class Proxy < ::Jenkins2::ResourceProxy
				attr_accessor :id
				include ::Jenkins2::RUD

				def create(config_xml)
					connection.post('createItem', config_xml, name: id) do |req|
						req['Content-Type'] = 'text/xml'
					end.code == '200'
				end

				def copy(from)
					connection.post('createItem', nil, name: id, from: from, mode: 'copy').code == '302'
				end

				def disable
					connection.post(build_path('disable')).code == '302'
				end

				def enable
					connection.post(build_path('enable')).code == '302'
				end

				def build(build_parameters={})
					if build_parameters.empty?
						connection.post(build_path('build'))
					else
						connection.post(build_path('buildWithParameters'), nil, build_parameters)
					end.code == '201'
				end

				def polling
					connection.post(build_path('polling')).code == '302'
				end
			end
		end
	end
end
