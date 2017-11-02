module Jenkins2
	module API
		module Plugins
			def plugins( **params )
				Proxy.new connection, "pluginManager", params
			end

			class Proxy < ::Jenkins2::ResourceProxy
				def install( *short_names )
					path = build_path 'install'
					form_data = short_names.flatten.inject({}) do |memo,obj|
						memo.merge "plugin.#{obj}.default" => 'on'
					end.merge( 'dynamicLoad' => 'Install without restart' )
					connection.post( path, ::URI.encode_www_form( form_data ) )
				end

				def upload( hpi_file )
				end

				def plugin( id, params={} )
					path = build_path 'plugin', id
					Plugin::Proxy.new connection, path, params
				end
			end

			module Plugin
				class Proxy < ::Jenkins2::ResourceProxy
					def uninstall
						path = build_path 'doUninstall'
						form_data = { 'Submit' => 'Yes', 'json' => '{}' }
						connection.post( path, ::URI.encode_www_form( form_data ) )
					end

					def active?
						raw.instance_of? Net::HTTPOK and subject['active']
					end
				end
			end
		end
	end
end
