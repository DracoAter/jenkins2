require 'optparse/uri'
require_relative 'cmdparse'
require_relative 'client'
require_relative 'log'

module Jenkins2
	class CommandLine
		attr_accessor :global_options
		attr_accessor :command_options
		
		def initialize( args )
			@global_options = OptionParser::OptionMap.new
			@log_options = { verbose: 0, log: STDOUT }
			@command_options = OptionParser::OptionMap.new
			global = CommandParser.new 'Usage: jenkins [global-options] <command> [options]' do |opts|
				opts.separator ''
				opts.separator "Global options (accepted by all commands):"
				opts.on '-s', '--server URL', URI, 'Jenkins Server Url' do |opt|
					@global_options[:server] = opt
				end
				opts.on '-u', '--user USER', 'Jenkins API user' do |opt|
					@global_options[:user] = opt
				end
				opts.on '-k', '--key KEY', 'Jenkins API key' do |opt|
					@global_options[:key] = opt
				end
				opts.on '-c', '--config [PATH]', 'Use configuration file. Instead of providing '\
					'server, user and key through command line, you can do that with configuration file. '\
					'File format is json: { "server": "http://jenkins.example.com", "user": "admin", '\
					'"key": "123456" }. Options provided in command line will overwrite ones from '\
					'configuration file. Program looks for ~/.jenkins2.json if no PATH is provided.' do |opt|
					@global_options[:config] = opt || ::File.join( ENV['HOME'], '.jenkins2.json' )
				end
				opts.on '-l', '--log FILE', 'Log file. Prints to standard out, if not provided' do |opt|
					@log_options[:log] = opt
				end
				opts.on '-v', '--verbose', 'Print more info. Up to -vvv. Prints only errors by default.' do
					@log_options[:verbose] += 1
				end
				opts.on '-h', '--help', 'Show help' do
					@global_options[:help] = true
				end
				opts.on '-V', '--version', 'Show version' do
					puts VERSION
					exit
				end

				opts.separator ''
				opts.separator 'For command specific options run: jenkins2 --help <command>'
				opts.separator ''
				opts.command 'version', 'Outputs the current version of Jenkins'
				opts.command 'prepare-for-shutdown', 'Stop executing new builds, so that the system can '\
					'be eventually shut down safely.'
				opts.command 'cancel-shutdown', 'Cancel the effect of "prepare-for-shutshow" command.'
				opts.command 'wait-nodes-idle', 'Wait for all nodes to become idle. Is expected to be '\
					'called after "prepare_for_shutdown", otherwise new builds will still be run.' do |cmd|
					cmd.on '-m', '--max-wait-minutes INT', Integer, 'Wait for INT minutes at most. '\
						'Default 60' do |opt|
						@command_options[:max_wait_minutes] = opt
					end
				end
				opts.command 'offline-node', 'Stop using a node for performing builds temporarily, until '\
					'the next "online-node" command.' do |cmd|
					cmd.on '-n', '--node NAME', 'Name of the node or empty for master' do |opt|
						@command_options[:node] = opt
					end
					cmd.on '-m', '--message MESSAGE', 'Record the note about why you are '\
						'disconnecting this node' do |opt|
						@command_options[:message] = opt
					end
				end
				opts.command 'online-node', 'Resume using a node for performing builds, to cancel out '\
					'the earlier "offline-node" command.' do |cmd|
					cmd.on '-n', '--node [NAME]', 'Name of the node or empty for master' do |opt|
						@command_options[:node] = opt
					end
				end
				opts.command 'connect-node', 'Connects a node, i.e. starts Jenkins slave on a node.' do |cmd|
					cmd.on '-n', '--node [NAME]', 'Name of the node or empty for master' do |opt|
						@command_options[:node] = opt
					end
				end
				opts.command 'disconnect-node', 'Disconnects a node.' do |cmd|
					cmd.on '-n', '--node [NAME]', 'Name of the node or empty for master' do |opt|
						@command_options[:node] = opt
					end
					cmd.on '-m', '--message MESSAGE', 'Reason, why the node is being disconnected.' do |opt|
						@command_options[:message] = opt
					end
				end
				opts.command 'wait-node-idle', 'Wait for the node to become idle. Make sure you run '\
					'"offline-node" first.' do |cmd|
					cmd.on '-n', '--node [NAME]', 'Name of the node or empty for master' do |opt|
						@command_options[:node] = opt
					end
					cmd.on '-m', '--max-wait-minutes INT', Integer, 'Wait for INT minutes at most. '\
						'Default 60' do |opt|
						@command_options[:max_wait_minutes] = opt
					end
				end
				opts.command 'get-node', 'Returns the node definition XML.' do |cmd|
					cmd.on '-n', '--node [NAME]', 'Name of the node or empty for master' do |opt|
						@command_options[:node] = opt
					end
				end
				opts.command 'update-node', 'Updates the node definition XML from stdin or file.' do |cmd|
					cmd.on '-n', '--node [NAME]', 'Name of the node or empty for master' do |opt|
						@command_options[:node] = opt
					end
					cmd.on '-x', '--xml-config FILE', 'File to read definition from. Omit this to read from stdin' do |opt|
						@command_options[:xml_config] = IO.read( opt )
					end
				end
				opts.command 'build', 'Starts a build.' do |cmd|
					cmd.on '-j', '--job NAME', 'Name of the job' do |opt|
						@command_options[:job] = opt
					end
					cmd.on '-p', '--params KEY=VALUE[,KEY=VALUE...]', Array, 'Build parameters, where keys are'\
						' names of variables' do |opt|
						@command_options[:params] = opt.collect{|i| i.split( '=', 2 ) }.to_h
					end
				end
				opts.command 'install-plugin', 'Installs a plugin from url or by short name. '\
					'Provide either --url or --name.' do |cmd|
					cmd.on '-u', '--uri URI', URI, 'Uri to install plugin from.' do |opt|
						@command_options[:uri] = opt
					end
					cmd.on '-n', '--name SHORTNAME', 'Plugin short name (like thinBackup).' do |opt|
						@command_options[:name] = opt
					end
				end
			end
			begin
				global.parse!( args )
				@global_options[:command] = global.command_name
				if @global_options[:config]
					from_file = JSON.parse( IO.read( @global_options[:config] ), symbolize_names: true )
					@global_options = from_file.merge( @global_options )
				end
				Log.init @log_options
				if @global_options[:help]
					Log.unknown { global.help }
					exit
				end
				raise OptionParser::MissingArgument, :command unless @global_options[:command]
			rescue OptionParser::InvalidOption, OptionParser::MissingArgument => e
				Log.fatal { e.message }
				Log.fatal { global.help }
				exit 1
			end
			Log.debug { "Options: #{@global_options}\nUnparsed args: #{ARGV}" }
		end

		def run
			jc = Client.new( @global_options )
			jc.send( @global_options[:command].gsub( '-', '_' ), @command_options )
		end
	end
end

