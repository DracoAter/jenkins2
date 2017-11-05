module Jenkins2
	module API
		module Root
			def root( **params )
				Proxy.new connection, '', params
			end

			def version
				connection.head( '/' )['X-Jenkins']
			end

			def quiet_down
				connection.post 'quietDown'
			end

			def cancel_quiet_down
				connection.post 'cancelQuietDown'
			end

			def restart
				connection.post 'safeRestart'
			end

			def restart!
				connection.post 'restart'
			end

			class Proxy < ::Jenkins2::ResourceProxy
			end
		end
	end
end
