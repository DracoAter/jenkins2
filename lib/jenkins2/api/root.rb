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
				connection.post( 'quietDown' ).code == '302'
			end

			def cancel_quiet_down
				connection.post( 'cancelQuietDown' ).code == '302'
			end

			def restart
				connection.post( 'safeRestart' ).code == '302'
			end

			def restart!
				connection.post( 'restart' ).code == '302'
			end

			class Proxy < ::Jenkins2::ResourceProxy
			end
		end
	end
end
