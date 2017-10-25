require 'net/http'
require 'openssl'
require 'json'

require_relative 'resource_proxy'
require_relative 'api/credentials'
require_relative 'api/plugins'

module Jenkins2
	class Connection
		include Jenkins2::API::Credentials
		include Jenkins2::API::Plugins

		attr_reader :connection

		# Creates a "connection" to Jenkins.
		# Parameter:
		# +server+:: Jenkins Server URL.
		def initialize( url )
			@server = url
			@crumb = nil
			@connection = self
		end

		# Add basic auth to existing connection. Returns self.
		# Parameters:
		# +user+:: Jenkins API user.
		# +key+:: Jenkins API key.
		def basic_auth( user, key )
			@user, @key = user, key
			self
		end

		def get( path, params={}, &block )
			api_request( Net::HTTP::Get, build_uri( ::File.join( path, 'api/json' ), params ), &block )
		end

		def post( path, body=nil, headers=nil, &block )
			api_request( Net::HTTP::Post, build_uri( path ), body, headers, &block )
		end

		def build_uri( relative_or_absolute, params={} )
			result = ::URI.parse relative_or_absolute
			result = ::URI.parse ::File.join( @server, ::URI.escape( relative_or_absolute ) ) unless result.absolute?
			result.query = ::URI.encode_www_form params
			result
		end

		def api_request( method, uri, body=nil, headers=nil )
			req = method.new( URI( uri ), headers )
			req.basic_auth @user, @key if @user and @key
			req.body = body
			yield req if block_given?
			Log.debug { "Request uri: #{req.uri}" }
			Log.debug { "Request content_type: #{req.content_type}, body: #{req.body}" }
			Net::HTTP.start( req.uri.hostname, req.uri.port, use_ssl: req.uri.scheme == 'https', verify_mode: OpenSSL::SSL::VERIFY_NONE ) do |http|
				begin
					req[@crumb["crumbRequestField"]] = @crumb["crumb"] if @crumb
					response = http.request req
					handle_response( response )
				rescue Net::HTTPServerException => e
					if e.message == "403 \"No valid crumb was included in the request\""
						update_crumbs
						retry
					else
						raise
					end
				end
			end
		end

		def update_crumbs
			@crumb = get '/crumbIssuer'
		end

		def handle_response( response )
			Log.debug { "Response: #{response.code}, #{response.body}" }
			case response
			when Net::HTTPSuccess
				begin
					JSON.parse response.body
				rescue =>
					response
				end
			when Net::HTTPClientError, Net::HTTPServerError
				response.value
			else
				response
			end
		end
	end
end
