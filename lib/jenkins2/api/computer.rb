# frozen_string_literal: true

require_relative 'rud'

require 'cgi'

module Jenkins2
	class API
		module Computer
			def computer(id=nil, **params)
				proxy = Proxy.new connection, 'computer', params
				proxy.id = id
				proxy
			end

			class Proxy < ::Jenkins2::ResourceProxy
				attr_accessor :id
				include ::Jenkins2::API::RUD

				def launch_agent
					connection.post(build_path('launchSlaveAgent')).code == '302'
				end

				def create
					form_data = { name: @id, type: 'hudson.slaves.DumbSlave$DescriptorImpl', json: '{}' }
					@id = nil
					path = build_path 'doCreateItem'
					connection.post(path, ::URI.encode_www_form(form_data)).code == '302'
				end

				def disconnect(offline_message=nil)
					path = build_path 'doDisconnect'
					body = "offlineMessage=#{::CGI.escape offline_message}" unless offline_message.nil?
					connection.post(path, body).code == '302'
				end

				def toggle_offline(offline_message=nil)
					path = build_path 'toggleOffline'
					body = "offlineMessage=#{::CGI.escape offline_message}" unless offline_message.nil?
					connection.post(path, body).code == '302'
				end

				def online?
					not ( offline or temporarilyOffline)
				end
			end
		end
	end
end
