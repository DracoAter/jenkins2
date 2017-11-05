module Jenkins2
	module API
		module User
			def me( **params )
				Me::Proxy.new connection, 'me', params
			end

			def user( id, **params )
				proxy = Proxy.new connection, 'user', params
				proxy.id = id
				proxy
			end
			
			def people( **params )
				People::Proxy.new connection, 'people', params
			end

			class Proxy < ::Jenkins2::ResourceProxy
				attr_accessor :id
			end

			module Me
				class Proxy < ::Jenkins2::ResourceProxy
				end
			end

			module People
				class Proxy < ::Jenkins2::ResourceProxy
				end
			end
		end
	end
end