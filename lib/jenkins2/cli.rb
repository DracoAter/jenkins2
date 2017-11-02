module Jenkins2
	class CLI
		attr_reader :options

		def initialize( options={}, command=[] )
			@options = options
			@command = command
			@log_opts = {}
			@parser = nil
		end

		def run
			Log.unknown summary
		end

		def parse( args )
			add_options
			parser.order! args do |nonopt|
				@command << nonopt
				if command_to_class
					return command_to_class.new( options, @command ).parse( args )
				else
					next
				end
			end
			self
		end

		def summary
			result = ''
			if self.class.subcommands.empty?
				result += global_parser.to_s
			else
				parser.separator 'Commands:'
				self.class.subcommands.each do |sc|
					key = sc.class_to_command
					parser.base.append( OptionParser::Switch::NoArgument.new( key, nil, [key], nil, nil,
						[sc.description], Proc.new{ OptionParser.new( &block ) } ), [], [key] )
					sc.new.summary
				end
			end
			result + parser.to_s
		end

		def self.description
			''
		end

		private

		# This method should be overwritten in subclasses
		def add_options
		end

		def parser
			return @parser if @parser
			if @command.empty?
				@parser = global_parser
			else
				@parser = OptionParser.new
				@parser.banner = 'Command:'
				key = @command.join ' '
				@parser.top.append( OptionParser::Switch::NoArgument.new( key, nil, [key], nil,
					nil, [self.class.description], Proc.new{ OptionParser.new( &block ) } ), [], [key] )
				@parser.separator 'Command Options:'
			end
			@parser
		end

		def global_parser
			@global_parser ||= OptionParser.new do |parser|
				parser.banner = 'Usage: jenkins2 [global-options] <command> [options]'
				parser.separator ''
				parser.separator 'Global options (accepted by all commands):'
				parser.on '-s', '--server URL', ::URI, 'Jenkins Server Url' do |s|
					options[:server] = s
				end
				parser.on '-u', '--user USER', 'Jenkins API User' do |u|
					options[:user] = u
				end
				parser.on '-k', '--key KEY', 'Jenkins API Key' do |k|
					options[:key] = k
				end
				parser.on '-c', '--config [PATH]', 'Use configuration file. Instead of providing '\
					'server, user and key through command line, you can do that with configuration file. '\
					'File format is json: { "server": "http://jenkins.example.com", "user": "admin", '\
					'"key": "123456" }. Options provided in command line will overwrite ones from '\
				'configuration file. Program looks for ~/.jenkins2.json if no PATH is provided.' do |c|
					options[:config] = opt || ::File.join( ENV['HOME'], '.jenkins2.json' )
				end
				parser.on '-l', '--log FILE', 'Log file. Prints to standard out, if not provided' do |l|
					@log_opts[:log] = opt
				end
				parser.on '-v', '--verbose', 'Print more info. Up to -vvv. Prints only errors by default.' do
					@log_opts[:verbose] += 1
				end
				parser.on '-h', '--help', 'Show help' do
					options[:help] = true
				end
				parser.on '-V', '--version', 'Show version' do
					puts VERSION
					exit
				end
				parser.separator ''
				parser.separator 'For command specific options run: jenkins2 --help <command>'
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
			to_s.split('::').last.gsub(/(.)([A-Z])/, '\1-\2').downcase
		end

		def self.subcommands
			constants( false ).collect{|c| const_get( c ) }.select do |c|
				c.kind_of?( Class ) and c.superclass == Jenkins2::CLI
			end.sort_by(&:to_s)
		end
	end
end
