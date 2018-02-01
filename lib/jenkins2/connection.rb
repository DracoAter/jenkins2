# frozen_string_literal: true

require 'net/http'
require 'openssl'
require 'json'

module Jenkins2
	class Connection
		# Creates a "connection" to Jenkins.
		# Parameter:
		# +server+:: Jenkins Server URL.
		def initialize(url)
			@server = url
			@crumb = nil
		end

		# Add basic auth to existing connection. Returns self.
		# Parameters:
		# +user+:: Jenkins API user.
		# +key+:: Jenkins API key.
		def basic_auth(user, key)
			@user, @key = user, key
			self
		end

		def get_json(path, params={}, &block)
			get(::File.join(path, 'api/json'), params, &block)
		end

		def get(path, params={}, &block)
			api_request(Net::HTTP::Get, build_uri(path, params), &block)
		end

		def head(path, params={}, &block)
			api_request(Net::HTTP::Head, build_uri(path, params), &block)
		end

		def post(path, body=nil, params={}, &block)
			headers = { 'Content-Type' => 'application/x-www-form-urlencoded' }
			api_request(Net::HTTP::Post, build_uri(path, params), body, headers, &block)
		end

		def build_uri(relative_or_absolute, params={})
			result = ::URI.parse relative_or_absolute
			result = ::URI.parse ::File.join(@server.to_s, relative_or_absolute) unless result.absolute?
			result.query = ::URI.encode_www_form params
			result
		end

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

		def update_crumbs
			@crumb = JSON.parse(get_json('/crumbIssuer').body)
		end

		def handle_response(response)
			Log.debug{ "Response: #{response.code}, #{response.body}" }
			case response
			when Net::HTTPNotFound
				raise Jenkins2::NotFoundError, response
			when Net::HTTPBadRequest
				raise Jenkins2::BadRequestError, response
			when Net::HTTPServiceUnavailable
				raise Jenkins2::ServiceUnavailableError, response
			when Net::HTTPClientError, Net::HTTPServerError # 4XX, 5XX
				response.value
			else
				response
			end
		end
	end
end
