require 'optparse'

module Jenkins2
	class CommandParser < OptionParser
		attr_reader :command_name

		def command( key, desc, &block )
			sw = OptionParser::Switch::NoArgument.new( key, nil, [key], nil, nil, [desc],
				Proc.new{ OptionParser.new( &block ) } ), [], [key]
			commands[key.to_s] = sw[0]
		end

		def parse!( argv=default_argv )
			@command_name = argv.detect{|c| commands.has_key? c }
			if command_name
				#create temporary parser with option definitions from both: globalparse and subparse
				OptionParser.new do |parser|
					parser.instance_variable_set(:@stack,
						commands[command_name.to_s].block.call.instance_variable_get(:@stack) + @stack)
				end.parse! argv
			else
				super( argv )
			end
		end

		def commands
			@commands ||= {}
		end

		private
		def summarize(to = [], width = @summary_width, max = width - 1, indent = @summary_indent, &blk)
			super(to, width, max, indent, &blk)
			if command_name and commands.has_key?( command_name )
				to << "Command:\n"
				commands[command_name].summarize( {}, {}, width, max, indent ) do |l|
					to << (l.index($/, -1) ? l : l + $/)
				end
				to << "Command options:\n"
				commands[command_name].block.call.summarize( to, width, max, indent, &blk )
			else
				to << "Commands:\n"
				commands.each do |name, command|
					command.summarize( {}, {}, width, max, indent ) do |l|
						to << (l.index($/, -1) ? l : l + $/)
					end
				end
			end
			to
		end
	end
end
