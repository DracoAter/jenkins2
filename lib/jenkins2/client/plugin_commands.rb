module Jenkins2
	class Client
		module PluginCommands
			# Installs plugins by short name (like +thinBackup+).
			# +names+:: List of short names.
			def install_plugins( *names )
				api_request( :post, '/pluginManager/install' ) do |req|
					req.form_data = names.flatten.inject({}) do |memo,obj|
						memo.merge "plugin.#{obj}.default" => 'on'
					end.merge( 'dynamicLoad' => 'Install without restart' )
				end
			end

			# Installs a plugin by uploading *.hpi or *.jpi file.
			# +plugin_file+:: A *.hpi or *.jpi file itself ( not some path )
			def upload_plugin( plugin_file )
				api_request( :post, '/pluginManager/uploadPlugin' ) do |req|
					req.body = plugin_file
					req.content_type = 'multipart/form-data'
				end
			end

			# Lists installed plugins
			def list_plugins
				api_request( :get, '/pluginManager/api/json?depth=1' )['plugins']
			end

			# Checks, if all of the plugins from the passed list are installed
			# +names+:: List of short names of plugins (like +thinBackup+).
			def plugins_installed?( *names )
				plugins = list_plugins
				return false if plugins.nil?
				names.flatten.all? do |name|
					plugins.detect{|p| p['shortName'] == name and !p['deleted'] }
				end
			end

			# Uninstalls a plugin
			# +name+:: Plugin short name
			def uninstall_plugin( name )
				api_request( :post, "/pluginManager/plugin/#{name}/doUninstall" ) do |req|
					req.form_data = { 'Submit' => 'Yes', 'json' => '{}' }
				end
			end

			def wait_plugins_installed( *names, max_wait_minutes: 2 )
				Wait.wait( max_wait_minutes: max_wait_minutes ) do
					plugins_installed? names
				end
			end
		end
	end
end
