require_relative 'test_helper'

module Jenkins2
	module UnitTest
		class CLITest < Minitest::Test
			PARSED_ARGS = { server: ::URI.parse( 'http://jenkins.com' ), user: 'admin', key: 'as213t2e' }

			GLOBAL_SUMMARY = %{Usage: jenkins2 [global-options] <command> [options]

Global options (accepted by all commands):
    -s, --server URL                 Jenkins Server Url
    -u, --user USER                  Jenkins API User
    -k, --key KEY                    Jenkins API Key
    -c, --config [PATH]              Use configuration file. Instead of providing server, user and key through command line, you can do that with configuration file. File format is json: { "server": "http://jenkins.example.com", "user": "admin", "key": "123456" }. Options provided in command line will overwrite ones from configuration file. Program looks for ~/.jenkins2.json if no PATH is provided.
    -l, --log FILE                   Log file. Prints to standard out, if not provided
    -v, --verbose                    Print more info. Up to -vvv. Prints only errors by default.
    -h, --help                       Show help
    -V, --version                    Show version

For command specific options run: jenkins2 --help <command>

}
			COMMANDS_SUMMARY = %{Commands:
    cancel-quiet-down                Cancel previously issued quiet-down command
    install-plugin                   Installs a plugin
    list-plugins                     Lists all installed plugins
    me                               Authenticated user info
    quiet-down                       Put Jenkins into the quiet mode, wait for existing builds to be completed.
    restart                          Restart Jenkins
    show-plugin                      Show plugin info
    uninstall-plugin                 Uninstalls a plugin
    version                          Jenkins version
}

			COMMAND_SUMMARY = %{Command:
    install-plugin                   Installs a plugin
Command Options:
    -n, --name SHORTNAME             Plugin short name (like thinBackup).
}

			def setup
				@subj = Jenkins2::CLI.new
				@args = %w{-s http://jenkins.com -k as213t2e --user admin}
			end

			def teardown
			end

			def test_parse_global_options
				result = @subj.parse @args
				assert_equal PARSED_ARGS, @subj.options
				assert_equal Jenkins2::CLI, result.class
			end

			def test_parse_global_options_with_command
				args = @args + %w{restart}
				result = @subj.parse( args )
				assert_equal PARSED_ARGS, @subj.options
				assert_equal Jenkins2::CLI::Restart, result.class
			end

			def test_parse_global_options_with_2_word_command
				args = @args + %w{install-plugin}
				result = @subj.parse( args )
				assert_equal PARSED_ARGS, @subj.options
				assert_equal Jenkins2::CLI::InstallPlugin, result.class
			end

			def test_parse_global_options_with_2_word_command_separated_by_space
				args = @args + %w{install plugin}
				result = @subj.parse( args )
				assert_equal PARSED_ARGS, @subj.options
				assert_equal Jenkins2::CLI::InstallPlugin, result.class
			end

			def test_parse_global_options_with_2_word_command_and_command_options
				args = @args + %w{install-plugin -n thinBackup}
				result = @subj.parse( args )
				assert_equal PARSED_ARGS.merge( name: 'thinBackup' ), @subj.options
				assert_equal Jenkins2::CLI::InstallPlugin, result.class
			end

			def test_parse_command_options_before_command
				args = @args + %w{-s http://jenkins.com -n thinBackup install-plugin}
				exc = assert_raises OptionParser::InvalidOption do
					@subj.parse( args )
				end
				assert_equal 'invalid option: -n', exc.message
			end

			def test_parse_global_options_after_command_with_no_options
				args = %w{version} + @args
				exc = assert_raises OptionParser::InvalidOption do
					@subj.parse( args )
				end
				assert_equal 'invalid option: -s', exc.message
			end

			def test_parse_global_options_after_command_that_accepts_options
				args = %w{uninstall-plugin -s http://jenkins.com -n thinBackup}
				exc = assert_raises OptionParser::InvalidOption do
					@subj.parse( args )
				end
				assert_equal 'invalid option: -s', exc.message
			end

			def test_summary_no_commands
				result = @subj.parse( [] )
				assert_equal GLOBAL_SUMMARY + COMMANDS_SUMMARY, result.summary
			end

			def test_print_help_part_command
				result = @subj.parse( %w{install} )
				assert_equal GLOBAL_SUMMARY + COMMANDS_SUMMARY, result.summary
			end

			def test_print_help_with_full_command
				result = @subj.parse( %w{install-plugin} )
				assert_equal GLOBAL_SUMMARY + COMMAND_SUMMARY, result.summary
			end
		end
	end
end
