require 'uri'
require 'net/http'
require 'json'

require_relative 'log'

module Jenkins
	# The entrance point for your Jenkins remote management.
	class Client
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
			api_request( :get, '/' )['X-Jenkins']
		end

		# Stops executing new builds, so that the system can be eventually shut down safely.
		# Parameters are ignored
		def prepare_for_shutdown( **args )
			api_request( :post, '/quietDown' )
		end

		# Cancels the effect of +prepare-for-shutshow+ command.
		# Parameters are ignored
		def cancel_shutdown( **args )
			api_request( :post, '/cancelQuietDown' )
		end

		# Waits for all the nodes to become idle or until +max_wait_minutes+ pass. Is expected to be
		# called after +prepare_for_shutdown+, otherwise new builds will still be run.
		# +max_wait_minutes+:: Maximum wait time in minutes. Default 60.
		def wait_nodes_idle( max_wait_minutes: 60 )
			max_wait_minutes.times do |i|
				response = api_request( :get, '/computer/api/json' )
				break if response === Net::HTTPSuccess && JSON.parse( response.body )['busyExecutors'].zero?
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
					req.body = URI.escape "offlineMessage=#{message}" if message
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
					req.body = URI.escape "offlineMessage=#{message}" if message
				end
			end
		end

		# Waits for node to become idle or until +max_wait_minutes+ pass.
		# +node+:: Node name, <tt>(master)</tt> for master.
		# +max_wait_minutes+:: Maximum wait time in minutes. Default 60.
		def wait_node_idle( node: '(master)', max_wait_minutes: 60 )
			max_wait_minutes.times do |i|
				response = api_request( :get, "/computer/#{node}/api/json" )
				break if response.code == '200' && JSON.parse( response.body )['idle']
				sleep 60
			end
		end

		# Returns the node definition XML.
		# +node+:: Node name, <tt>(master)</tt> for master.
		def get_node( node: '(master)' )
			response = api_request( :get, "/computer/#{node}/config.xml" )
			response.body
		end

		# Updates the node definition XML
		# Keyword parameters:
		# +node+:: Node name, <tt>(master)</tt> for master.
		# +xml_config+:: New configuration in xml format.
		def update_node( node: '(master)', xml_config: nil )
			xml_config = STDIN.read if xml_config.nil?
			api_request( :post, "/computer/#{node}/config.xml" ) do |req|
				req.body = xml_config
			end
		end

		# Checks if node is online (= not temporarily offline )
		# +node+:: Node name. Use <tt>(master)</tt> for master.
		def node_online?( node )
			response = api_request( :get, "/computer/#{node}/api/json" )
			if response.code == '200'
				return JSON.parse( response.body )['temporarilyOffline'] == false
			else
				Log.fatal "Failed to get #{node} state from jenkins. Error code: #{response.code}. "\
					"Response: #{response.body}"
			end
		end

		# Checks if node is connected, i.e. Master connected and launched client on it.
		# +node+:: Node name. Use <tt>(master)</tt> for master.
		def node_connected?( node )
			response = api_request( :get, "/computer/#{node}/api/json" )
			if response.code == '200'
				return JSON.parse( response.body )['offline'] == false
			else
				Log.fatal "Failed to get #{node} state from jenkins. Error code: #{response.code}. "\
					"Response: #{response.body}"
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

		# Plugin Commands

		# Installs a plugin from url or by short name (like +thinBackup+).
		def install_plugin( uri: nil, name: nil )
			if name
				Log.debug { "Installing plugin: #{name}" }
				api_request( :post, '/pluginManager/install' ) do |req|
					req.form_data = { "plugin.#{name}.default" => 'on' }
				end
			elsif uri
				Log.info "Not Implemented"
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

		# Checks if some plugin is installed
		# +short_name+:: Short name of plugin (like +thinBackup+).
		def plugin_installed?( short_name )
			response = api_request( :get, '/pluginManager/api/json?depth=1' )
			JSON.parse( response.body )['plugins'].any?{|p| p['shortName'] == short_name }
		end

		# Adds credentials to Jenkins
		def add_credentials
		end

		private
		def api_request( method, path )
			uri = URI.join( @server, path )
			Log.debug { "Request: #{method} #{uri}" }
			req = case method
				when :get then Net::HTTP::Get
				when :post then Net::HTTP::Post
			end.new uri
			req.basic_auth @user, @key
			yield req if block_given?
			response = Net::HTTP.start( uri.hostname, uri.port ){|http| http.request req }
			Log.debug { "Response: #{response.code}, #{response.body}" }
			response
		end
	end
end
