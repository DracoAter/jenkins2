require 'optparse/uri'

require_relative 'cli/credentials'
require_relative 'cli/nodes'
require_relative 'cli/root'
require_relative 'cli/plugins'
require_relative 'cli/user'
require_relative 'cli/view'

module Jenkins2
	class CLI
		attr_reader :options, :errors

		def initialize( options={} )
			@options = options
			@command = []
			@errors = []
			@log_opts = {}
			@parser = nil
			add_options
		end

		def call
			if options[:help]
				summary
			elsif !errors.empty?
				errors.join( "\n" ) + "\n" + summary
			else
				run
			end
		end

		def parse( args )
			parser.order! args do |nonopt|
				@command << nonopt
				if command_to_class
					return command_to_class.new( options ).parse( args )
				else
					next
				end
			end
			missing = mandatory_arguments.select{|a| options[a].nil? }
			unless missing.empty?
				@errors << "Missing argument(s): #{missing.join(', ')}."
			end
			self
		end

		# This method should be overwritten in subclasses
		def self.description
			''
		end

		private

		# This method can be overwritten in subclasses, to add more mandatory arguments
		def mandatory_arguments
			[:server]
		end

		# This method should be overwritten in subclasses
		def add_options
		end

		# This method should be overwritten in subclasses
		def run
			summary
		end

		def summary
			if self.class.subcommands.empty?
				global_parser.to_s + parser.to_s
			else
				parser.separator 'Commands:'
				self.class.subcommands.each do |sc|
					key = sc.class_to_command
					parser.base.append( OptionParser::Switch::NoArgument.new( key, nil, [key], nil, nil,
						[sc.description], Proc.new{ OptionParser.new( &block ) } ), [], [key] )
				end
				parser.to_s
			end
		end

		def parser
			return @parser if @parser
			if self.class.class_to_command
				@parser = OptionParser.new
				@parser.banner = 'Command:'
				key = self.class.class_to_command
				@parser.top.append( OptionParser::Switch::NoArgument.new( key, nil, [key], nil,
					nil, [self.class.description], Proc.new{ OptionParser.new( &block ) } ), [], [key] )
			else
				@parser = global_parser
			end
			@parser
		end

		def global_parser
			@global_parser ||= OptionParser.new do |parser|
				parser.banner = 'Usage: jenkins2 [global-arguments] <command> [command-arguments]'
				parser.separator ''
				parser.separator 'Global arguments (accepted by all commands):'
				parser.on '-s', '--server URL', ::URI, 'Jenkins Server Url' do |s|
					@options[:server] = s
				end
				parser.on '-u', '--user USER', 'Jenkins API User' do |u|
					@options[:user] = u
				end
				parser.on '-k', '--key KEY', 'Jenkins API Key' do |k|
					@options[:key] = k
				end
				parser.on '-c', '--config [PATH]', 'Use configuration file. Instead of providing '\
					'server, user and key through command line, you can do that with configuration file. '\
					'File format is json: { "server": "http://jenkins.example.com", "user": "admin", '\
					'"key": "123456" }. Arguments provided in command line will overwrite ones from '\
					'configuration file. Program looks for ~/.jenkins2.json if no PATH is provided.' do |c|
					@options[:config] = c || ::File.join( ENV['HOME'], '.jenkins2.json' )
					config_file_options = JSON.parse( IO.read( options[:config] ), symbolize_names: true )
					@options = config_file_options.merge options
				end
				parser.on '-l', '--log FILE', 'Log file. Prints to standard out, if not provided' do |l|
					@options[:log] = l
				end
				parser.on '-v', '--verbose VALUE', Integer, 'Print more info. 1 up to 3. Prints only errors by default.' do |v|
					@options[:verbose] = v
				end
				parser.on '-h', '--help', 'Show help' do
					@options[:help] = true
				end
				parser.on '-V', '--version', 'Show version' do
					puts VERSION
					exit
				end
				parser.separator ''
				parser.separator 'For command specific arguments run: jenkins2 --help <command>'
				parser.separator ''
			end
		end

		def command_to_class
			const = @command.join('-').split('-').map(&:capitalize).join
			if self.class.const_defined?( const )
				klass = self.class.const_get( const )
				return klass if klass.kind_of?( Class ) and klass.superclass == Jenkins2::CLI
			end
			nil
		end

		def self.class_to_command
			to_s.split('::').last.gsub(/(.)([A-Z])/, '\1-\2').downcase if superclass == Jenkins2::CLI
		end

		def self.subcommands
			constants( false ).collect{|c| const_get( c ) }.select do |c|
				c.kind_of?( Class ) and c.superclass == Jenkins2::CLI
			end.sort_by(&:to_s)
		end

		def jc
			@jc ||= Jenkins2.connect options
		end
	end
end
