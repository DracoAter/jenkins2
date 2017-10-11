require 'net/http'
require 'openssl'
require 'json'

require_relative 'log'
require_relative 'uri'
require_relative 'wait'
require_relative 'client/credential_commands'
require_relative 'client/node_commands'
require_relative 'client/plugin_commands'

module Jenkins2
	# The entrance point for your Jenkins remote management.
	class Client
		include CredentialCommands
		include PluginCommands
		include NodeCommands
		# Creates a "connection" to Jenkins.
		# Keyword parameters:
		# +server+:: Jenkins Server URL.
		# +user+:: Jenkins API user. Can be omitted, if no authentication required.
		# +key+:: Jenkins API key. Can be omitted, if no authentication required.
		def initialize( **args )
			@server = args[:server]
			@user = args[:user]
			@key = args[:key]
			@crumb = nil
		end

		# Returns Jenkins version
		def version
			api_request( :get, '/', :raw )['X-Jenkins']
		end

		# Stops executing new builds, so that the system can be eventually shut down safely.
		# Parameters are ignored
		def prepare_for_shutdown( **args )
			api_request( :post, '/quietDown' )
		end

		# Forcefully restart Jenkins NOW!
		# Parameters are ignored
		def restart!( **args )
			api_request( :post, '/restart' )
		end
		
		# Cancels the effect of +prepare-for-shutdown+ command.
		# Parameters are ignored
		def cancel_shutdown( **args )
			api_request( :post, '/cancelQuietDown' )
		end

		# Waits for all the nodes to become idle or until +max_wait_minutes+ pass. Is expected to be
		# called after +prepare_for_shutdown+, otherwise new builds will still be run.
		# +max_wait_minutes+:: Maximum wait time in minutes. Default 60.
		def wait_nodes_idle( max_wait_minutes: 60 )
			Wait.wait( max_wait_minutes: max_wait_minutes ) do
				api_request( :get, '/computer/api/json' )['busyExecutors'].zero?
			end
		end

		# Job Commands

		# Starts a build
		# +job_name+:: Name of the job to build
		# +build_params+:: Build parameters as hash, where keys are names of variables.
		def build( **args )
			job, params = args[:job], args[:params]
			if params.nil? or params.empty?
				api_request( :post, "/job/#{job}/build" )
			else
				api_request( :post, "/job/#{job}/buildWithParameters" ) do |req|
					req.form_data = params
				end
			end
		end

		private
		def api_request( method, path, reply_with=:json )
			req = case method
				when :get then Net::HTTP::Get
				when :post then Net::HTTP::Post
			end.new( URI File.join( @server, URI.escape( path ) ) )
			Log.debug { "Request: #{method} #{req.uri}" }
			req.basic_auth @user, @key
			yield req if block_given?
			req.content_type ||= 'application/x-www-form-urlencoded'
			Log.debug { "Request content_type: #{req.content_type}, body: #{req.body}" }
			begin
				req[@crumb["crumbRequestField"]] = @crumb["crumb"] if @crumb
				response = Net::HTTP.start( req.uri.hostname, req.uri.port, use_ssl: req.uri.scheme == 'https', verify_mode: OpenSSL::SSL::VERIFY_NONE ) do |http|
					http.request req
				end
				handle_response( response, reply_with )
			rescue Net::HTTPServerException => e
				if e.message == "403 \"No valid crumb was included in the request\""
					update_crumbs
					retry
				else
					raise
				end
			end
		end

		def update_crumbs
			@crumb = api_request( :get, '/crumbIssuer/api/json' )
		end

		def handle_response( response, reply_with )
			Log.debug { "Response: #{response.code}, #{response.body}" }
			case response
			when Net::HTTPSuccess
				case reply_with
				when :json then JSON.parse response.body
				when :body then response.body
				when :raw then response
				end
			when Net::HTTPRedirection
				response['location']
			when Net::HTTPClientError, Net::HTTPServerError
				response.value
			else
				response.value
			end
		end
	end
end
