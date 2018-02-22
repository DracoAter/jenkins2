# frozen_string_literal: true

require 'optparse/uri'
require 'yaml'

require_relative 'version'
require_relative 'cli/credentials'
require_relative 'cli/nodes'
require_relative 'cli/role_strategy'
require_relative 'cli/root'
require_relative 'cli/plugins'
require_relative 'cli/user'
require_relative 'cli/view'

module Jenkins2
	class CLI
		attr_reader :options, :errors

		def initialize(options={})
			@options = options.dup
			@command = []
			@errors = []
			@parser = nil
			add_options
		end

		def call
			if options[:help]
				summary
			elsif options[:version]
				Jenkins2::VERSION
			elsif !errors.empty?
				errors.join("\n") + "\n" + summary
			else
				run
			end
		end

		def parse(args)
			parser.order! args do |nonopt|
				@command << nonopt
				return command_to_class.new(options).parse(args) if command_to_class
				next
			end
			missing = mandatory_arguments.select{|a| options[a].nil? }
			@errors << "Missing argument(s): #{missing.join(', ')}." unless missing.empty?
			self
		end

		# This method should be overwritten in subclasses
		def self.description; end

		def self.class_to_command
			to_s.split('::').last.gsub(/(.)([A-Z])/, '\1-\2').downcase if superclass == Jenkins2::CLI
		end

		def self.subcommands
			constants(false).collect{|c| const_get(c) }.select do |c|
				c.is_a?(Class) and c.superclass == Jenkins2::CLI
			end.sort_by(&:to_s)
		end

		private

		# This method can be overwritten in subclasses, to add more mandatory arguments
		def mandatory_arguments
			[:server]
		end

		# This method should be overwritten in subclasses
		def add_options; end

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
					parser.base.append(OptionParser::Switch::NoArgument.new(key, nil, [key], nil, nil,
						[sc.description], proc{ OptionParser.new(&block) }), [], [key])
				end
				parser.to_s
			end
		end

		def parser
			@parser ||= if (key = self.class.class_to_command)
				OptionParser.new do |parser|
					parser.banner = 'Command:'
					parser.top.append(OptionParser::Switch::NoArgument.new(key, nil, [key], nil,
						nil, [self.class.description], proc{ OptionParser.new(&block) }), [], [key])
				end
			else
				global_parser
			end
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
				parser.on '-c', '--config [PATH]', %(Read configuration file. All global options can be \
configured in configuration file. File format is yaml. Arguments provided in command line will \
overwrite those in configuration file. Program looks for .jenkins2.conf in current directory if \
no PATH is provided.) do |c|
					@options[:config] = c || ::File.join('.jenkins2.conf')
					config_file_options = YAML.load_file(options[:config])
					@options = config_file_options.merge options
				end
				parser.on '-l', '--log FILE', 'Log file. Prints to standard out, if not provided' do |l|
					@options[:log] = l
				end
				parser.on '-v', '--verbose VALUE', Integer, 'Print more info. 1 up to 3. Prints only '\
					'errors by default.' do |v|
					@options[:verbose] = v
				end
				parser.on '-h', '--help', 'Show help' do
					@options[:help] = true
				end
				parser.on '-V', '--version', 'Show version' do
					@options[:version] = true
				end
				parser.separator ''
				parser.separator 'For command specific arguments run: jenkins2 --help <command>'
				parser.separator ''
			end
		end

		def command_to_class
			const = @command.join('-').split('-').map(&:capitalize).join
			if self.class.const_defined?(const)
				klass = self.class.const_get(const)
				return klass if klass.is_a?(Class) and klass.superclass == Jenkins2::CLI
			end
			nil
		end

		def jc
			@jc ||= Jenkins2.connect options
		end
	end
end
