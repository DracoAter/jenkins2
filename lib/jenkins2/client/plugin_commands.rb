module Jenkins2
	class Client
		module PluginCommands
			# Installs plugins by short name (like +thinBackup+).
			# +names+:: Array of short names.
			def install_plugins( *names )
				api_request( :post, '/pluginManager/install' ) do |req|
					req.form_data = names.flatten.collect do |n|
						["plugin.#{n}.default", 'on']
					end.to_h.merge( 'dynamicLoad' => 'Install without restart' )
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

			# Checks if some plugin is installed
			# +short_name+:: Short name of plugin (like +thinBackup+).
			def plugin_installed?( short_name )
				plugins = list_plugins
				return false if plugins.nil?
				plugin = plugins.detect{|p| p['shortName'] == short_name }
				return false if plugin.nil?
				!plugin['deleted']
			end

			# Uninstalls a plugin
			# +name+:: Plugin short name
			def uninstall_plugin( name )
				api_request( :post, "/pluginManager/plugin/#{name}/doUninstall" ) do |req|
					req.form_data = { 'Submit' => 'Yes', 'json' => '{}' }
				end
			end

			def wait_plugins_installed( *names, max_wait_minutes: 2 )
				(1..(max_wait_minutes * 60)).step 5 do
					plugins = list_plugins.select{|i| names.flatten.include? i['shortName'] }
					return true if names.flatten.size == plugins.size and plugins.all?{|i| !i['deleted'] }
					sleep 5
				end
			end
		end
	end
end
