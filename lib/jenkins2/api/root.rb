module Jenkins2
	module API
		module Root
			def version
				connection.head( '/' )['X-Jenkins']
			end
				
			def me( **params )
				Me::Proxy.new connection, 'me', params
			end

			def quiet_down
				connection.post 'quietDown'
			end

			def cancel_quiet_down
				connection.post 'cancelQuietDown'
			end

			def restart!
				connection.post 'restart'
			end

			module Me
				class Proxy < ::Jenkins2::ResourceProxy
				end
			end
		end
	end
end
