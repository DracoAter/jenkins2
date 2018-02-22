# frozen_string_literal: true

require 'net/http'
require 'openssl'
require 'json'

module Jenkins2
	# Creates a "connection" to Jenkins and makes all the HTTP requests.
	class Connection
		# ==== Parameters:
		# +server+:: Jenkins Server URL.
		def initialize(server)
			@server = server
			@crumb = nil
		end

		# Add basic auth to existing connection. Returns self.
		# ==== Parameters:
		# +user+:: Jenkins API user.
		# +key+:: Jenkins API key.
		def basic_auth(user, key)
			@user, @key = user, key
			self
		end

		# Appends api/json to passed +path+ and makes GET request. Yields request, if block given.
		# ==== Parameters:
		# +path+:: Path to make request to. "api/json" will be appened to the end.
		# +params+:: Parameter hash. It will be converted to URL parameters.
		# +&block+:: Yields Net::HTTP::Get request.
		# ==== Returns:
		# Net::HTTP::Response
		def get_json(path, params={}, &block)
			get(::File.join(path, 'api/json'), params, &block)
		end

		# Makes GET request. Yields request, if block given.
		# ==== Parameters:
		# +path+:: Path to make request to.
		# +params+:: Parameter hash. It will be converted to URL parameters.
		# +&block+:: Yields Net::HTTP::Get request.
		# ==== Returns:
		# Net::HTTP::Response
		def get(path, params={}, &block)
			api_request(Net::HTTP::Get, build_uri(path, params), &block)
		end

		# Makes HEAD request. Yields request, if block given.
		# ==== Parameters:
		# +path+:: Path to make request to.
		# +params+:: Parameter hash. It will be converted to URL parameters.
		# +&block+:: Yields Net::HTTP::Head request.
		# ==== Returns:
		# Net::HTTP::Response
		def head(path, params={}, &block)
			api_request(Net::HTTP::Head, build_uri(path, params), &block)
		end

		# Makes POST request. Yields request, if block given.
		# ==== Parameters:
		# +path+:: Path to make request to.
		# +body+:: Post request body.
		# +params+:: Parameter hash. It will be converted to URL parameters.
		# +&block+:: Yields Net::HTTP::Post request.
		# ==== Returns:
		# Net::HTTP::Response
		def post(path, body=nil, params={}, &block)
			headers = { 'Content-Type' => 'application/x-www-form-urlencoded' }
			api_request(Net::HTTP::Post, build_uri(path, params), body, headers, &block)
		end

		# Builds URI. Appends parameters.
		# ==== Parameters:
		# +relative_or_absolute+:: Absolute URI or URI path. If path, Jenkins server will be prepended.
		# +params+:: Parameter hash. It will be converted to URL parameters.
		# ==== Returns:
		# Absolute URI with parameters
		def build_uri(relative_or_absolute, params={})
			result = ::URI.parse relative_or_absolute
			result = ::URI.parse ::File.join(@server.to_s, relative_or_absolute) unless result.absolute?
			result.query = ::URI.encode_www_form params
			result
		end

		# Makes request, using +method+ provided. Yields request, if block given. Retries request with
		# updated crumbs, if "No valid crumbs" error received.
		# ==== Parameters:
		# +method+:: Net:HTTP class to instantiate (e.g. Net::HTTP::Post, Net::HTTP::Get)
		# +url+:: Absolute URI to make request to.
		# +body+:: Request body if applicable.
		# +headers+:: Request headers.
		# ==== Returns:
		# Net::HTTP::Response
		def api_request(method, uri, body=nil, headers=nil)
			req = method.new(URI(uri), headers)
			req.basic_auth @user, @key if @user and @key
			req.body = body
			yield req if block_given?
			Net::HTTP.start(req.uri.hostname, req.uri.port,
				use_ssl: req.uri.scheme == 'https', verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
				begin
					req[@crumb['crumbRequestField']] = @crumb['crumb'] if @crumb
					Log.debug{ "Request uri: #{req.uri}" }
					Log.debug{ "Request content_type: #{req.content_type}, body: #{req.body}" }
					response = http.request req
					handle_response response
				rescue Jenkins2::NoValidCrumbMatcher
					update_crumbs
					retry
				end
			end
		end

		# Updates crumbs for current connection. These crumbs will be submitted with all requests.
		# ==== Returns:
		# Crumbs as hash
		def update_crumbs
			@crumb = JSON.parse(get_json('/crumbIssuer').body)
		end

		# Handles Jenkins response. Tries parsing error messages in some cases, then reraises
		# exception from Jenkins2 namespace.
		# ==== Returns:
		# HTTPResponse
		# ==== Raises:
		# Different Net::HTTP and Jenkins2 errors.
		def handle_response(response)
			Log.debug{ "Response: #{response.code}, #{response.body}" }
			case response
			when Net::HTTPNotFound
				raise Jenkins2::NotFoundError, response
			when Net::HTTPBadRequest
				raise Jenkins2::BadRequestError, response
			when Net::HTTPServiceUnavailable
				raise Jenkins2::ServiceUnavailableError, response
			when Net::HTTPInternalServerError
				raise Jenkins2::InternalServerError, response
			when Net::HTTPClientError, Net::HTTPServerError # 4XX, 5XX
				response.value
			else
				response
			end
		end
	end
end
