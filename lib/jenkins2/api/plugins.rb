# frozen_string_literal: true

module Jenkins2
	class API
		module Plugins
			def plugins(**params)
				Proxy.new connection, 'pluginManager', params
			end

			class Proxy < ::Jenkins2::ResourceProxy
				BOUNDARY = '----Jenkins2RubyMultipartClient' + rand(1_000_000).to_s

				def install(*short_names)
					path = build_path 'install'
					form_data = short_names.flatten.inject({}) do |memo, obj|
						memo.merge "plugin.#{obj}.default" => 'on'
					end.merge('dynamicLoad' => 'Install without restart')
					connection.post(path, ::URI.encode_www_form(form_data)).code == '302'
				end

				def upload(hpi_file, filename)
					body = "--#{BOUNDARY}\r\n"\
						"Content-Disposition: form-data; name=\"file0\"; filename=\"#{filename}\"\r\n"\
						"Content-Type: application/octet-stream\r\n\r\n"\
						"#{hpi_file}\r\n"\
						"--#{BOUNDARY}\r\n"\
						"Content-Disposition: form-data; name=\"json\"\r\n\r\n"\
						"\r\n\r\n--#{BOUNDARY}--\r\n"
					connection.post(build_path('uploadPlugin'), body) do |req|
						req['Content-Type'] = "multipart/form-data, boundary=#{BOUNDARY}"
					end.code == '302'
				end

				def plugin(id, params={})
					path = build_path 'plugin', id
					::Jenkins2::API::Plugin::Proxy.new connection, path, params
				end
			end
		end

		module Plugin
			class Proxy < ::Jenkins2::ResourceProxy
				def uninstall
					path = build_path 'doUninstall'
					form_data = { 'Submit' => 'Yes', 'json' => '{}' }
					connection.post(path, ::URI.encode_www_form(form_data)).code == '302'
				end

				def active?
					raw.instance_of? ::Net::HTTPOK and subject.active
				end
			end
		end
	end
end
