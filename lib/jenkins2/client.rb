require 'cgi'
require 'uri'
require 'net/http'
require 'json'

require_relative 'log'
require_relative 'client/credential_commands'
require_relative 'client/plugin_commands'

module Jenkins2
	# The entrance point for your Jenkins remote management.
	class Client
		include CredentialCommands
		include PluginCommands
		# Creates a "connection" to Jenkins.
		# Keyword parameters:
		# +server+:: Jenkins Server URL.
		# +user+:: Jenkins API user. Can be omitted, if no authentication required.
		# +key+:: Jenkins API key. Can be omitted, if no authentication required.
		def initialize( **args )
			@server = args[:server]
			@user = args[:user]
			@key = args[:key]
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

		# Cancels the effect of +prepare-for-shutdown+ command.
		# Parameters are ignored
		def cancel_shutdown( **args )
			api_request( :post, '/cancelQuietDown' )
		end

		# Waits for all the nodes to become idle or until +max_wait_minutes+ pass. Is expected to be
		# called after +prepare_for_shutdown+, otherwise new builds will still be run.
		# +max_wait_minutes+:: Maximum wait time in minutes. Default 60.
		def wait_nodes_idle( max_wait_minutes: 60 )
			max_wait_minutes.times do |i|
				break if api_request( :get, '/computer/api/json' )['busyExecutors'].zero?
				sleep 60
			end
		end

		# Node Commands

		# Sets node temporarily offline. Does nothing, if node is already offline.
		# +node+:: Node name, or <tt>(master)</tt> for master.
		# +message+:: Record the note about this node is being disconnected.
		def offline_node( node: '(master)', message: nil )
			if node_online?( node )
				api_request( :post, "/computer/#{node}/toggleOffline" ) do |req|
					req.body = "offlineMessage=#{CGI::escape message}" if message
				end
			end
		end

		# Sets node back online, if node is temporarily offline.
		# +node+:: Node name, <tt>(master)</tt> for master.
		def online_node( node: '(master)' )
			api_request( :post, "/computer/#{node}/toggleOffline" ) unless node_online?( node )
		end

		# Connects a node, if node is disconnected.
		# +node+:: Node name, <tt>(master)</tt> for master.
		def connect_node( node: '(master)' )
			api_request( :post, "/computer/#{node}/launchSlaveAgent" ) unless node_connected?( node )
		end

		# Disconnects a node.
		# +node+:: Node name, <tt>(master)</tt> for master.
		# +message+:: Reason why you the node is being disconnected.
		def disconnect_node( node: '(master)', message: nil )
			if node_connected? node
				api_request( :post, "/computer/#{node}/doDisconnect" ) do |req|
					req.body = "offlineMessage=#{CGI::escape message}" if message
				end
			end
		end

		# Waits for node to become idle or until +max_wait_minutes+ pass.
		# +node+:: Node name, <tt>(master)</tt> for master.
		# +max_wait_minutes+:: Maximum wait time in minutes. Default 60.
		def wait_node_idle( node: '(master)', max_wait_minutes: 60 )
			max_wait_minutes.times do |i|
				break if api_request( :get, "/computer/#{node}/api/json" )['idle']
				sleep 60
			end
		end

		# Returns the node definition XML.
		# +node+:: Node name, <tt>(master)</tt> for master.
		def get_node( node: '(master)' )
			api_request( :get, "/computer/#{node}/config.xml", :body )
		end

		# Updates the node definition XML
		# Keyword parameters:
		# +node+:: Node name, <tt>(master)</tt> for master.
		# +xml_config+:: New configuration in xml format.
		def update_node( node: '(master)', xml_config: nil )
			xml_config = STDIN.read if xml_config.nil?
			api_request( :post, "/computer/#{node}/config.xml", :body ) do |req|
				req.body = xml_config
			end
		end

		# Checks if node is online (= not temporarily offline )
		# +node+:: Node name. Use <tt>(master)</tt> for master.
		def node_online?( node )
			!api_request( :get, "/computer/#{node}/api/json" )['temporarilyOffline']
		end

		# Checks if node is connected, i.e. Master connected and launched client on it.
		# +node+:: Node name. Use <tt>(master)</tt> for master.
		def node_connected?( node )
			!api_request( :get, "/computer/#{node}/api/json" )['offline']
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
			uri = URI File.join( @server, path )
			req = case method
				when :get then Net::HTTP::Get
				when :post then Net::HTTP::Post
			end.new uri
			req.basic_auth @user, @key
			yield req if block_given?
			Log.debug { "Request: #{method} #{uri}" }
			Log.debug { "Request body: #{req.body}" }
			response = Net::HTTP.start( uri.hostname, uri.port ){ |http| http.request req }
			handle_response( response, reply_with )
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
				Log.error { "Response: #{response.code}, #{response.body}" }
				response.value
			else
				Log.error { "Response: #{response.code}, #{response.body}" }
				response.value
			end
		end
	end
end
