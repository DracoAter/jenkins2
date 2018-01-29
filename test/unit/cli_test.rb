require_relative 'test_helper'

module Jenkins2
	module UnitTest
		class CLITest < Minitest::Test
			PARSED_ARGS = { server: ::URI.parse( 'http://jenkins.com' ), user: 'admin', key: 'as213t2e' }

			GLOBAL_SUMMARY = %{Usage: jenkins2 [global-arguments] <command> [command-arguments]

Global arguments (accepted by all commands):
    -s, --server URL                 Jenkins Server Url
    -u, --user USER                  Jenkins API User
    -k, --key KEY                    Jenkins API Key
    -c, --config [PATH]              Use configuration file. Instead of providing server, user and key through command line, you can do that with configuration file. File format is json: { "server": "http://jenkins.example.com", "user": "admin", "key": "123456" }. Arguments provided in command line will overwrite ones from configuration file. Program looks for ~/.jenkins2.json if no PATH is provided.
    -l, --log FILE                   Log file. Prints to standard out, if not provided
    -v, --verbose VALUE              Print more info. 1 up to 3. Prints only errors by default.
    -h, --help                       Show help
    -V, --version                    Show version

For command specific arguments run: jenkins2 --help <command>

}
			COMMANDS_SUMMARY = %{Commands:
    add-job-to-view                  Adds jobs to view.
    cancel-quiet-down                Cancel previously issued quiet-down command.
    connect-node                     Reconnect node(s).
    create-node                      Creates a new node by reading stdin as a XML configuration.
    create-ssh-credentials           Creates username with ssh private key credentials. Jenkins must have ssh-credentials plugin installed.
    create-view                      Creates a new view by reading stdin as a XML configuration.
    delete-node                      Deletes node(s).
    delete-view                      Delete view(s).
    disconnect-node                  Disconnects node(s).
    get-node                         Dumps the node definition XML to stdout.
    get-view                         Dumps the view definition XML to stdout.
    install-plugin                   Installs a plugin either from a file, an URL, standard input or from update center.
    list-node                        Outputs the node list.
    list-online-node                 Outputs the online node list.
    list-plugins                     Lists all installed plugins.
    offline-node                     Stop using a node for performing builds temporarily, until the next \"online-node\" command.
    online-node                      Resume using a node for performing builds, to cancel out the earlier \"offline-node\" command.
    quiet-down                       Put Jenkins into the quiet mode, wait for existing builds to be completed.
    remove-job-from-view             Removes jobs from view.
    restart                          Restart Jenkins.
    safe-restart                     Safely restart Jenkins.
    show-plugin                      Show plugin info.
    uninstall-plugin                 Uninstalls a plugin.
    update-node                      Updates the node definition XML from stdin. The opposite of the get-node command.
    update-view                      Updates the view definition XML from stdin. The opposite of the get-view command.
    version                          Jenkins version.
    wait-node-offline                Wait for a node to become offline.
    wait-node-online                 Wait for a node to become online.
    who-am-i                         Reports your credentials.
}

			COMMAND_SUMMARY = %{Command:
    uninstall-plugin                 Uninstalls a plugin.
Mandatory arguments:
    -n, --name SHORTNAME             Plugin short name (like thinBackup).
}

			def setup
				@subj = Jenkins2::CLI.new
				@config_file = Tempfile.open('jenkins2.json') do |f|
					f.write('{"user":"fromconfigfile","verbose":"3"}')
					f
				end
				@args = %w{-s http://jenkins.com -k as213t2e --user admin}
			end

			def teardown
#				@config_file.unlink
			end

			def test_parse_arguments_mandatory_missing
				assert_equal ['Missing argument(s): server.'], @subj.parse( [] ).errors
			end

			def test_parse_global_arguments
				result = @subj.parse @args
				assert_equal PARSED_ARGS, @subj.options
				assert_equal Jenkins2::CLI, result.class
			end

			def test_parse_global_arguments_with_command
				args = @args + %w{restart}
				result = @subj.parse( args )
				assert_equal PARSED_ARGS, @subj.options
				assert_equal Jenkins2::CLI::Restart, result.class
			end

			def test_parse_global_arguments_with_2_word_command
				args = @args + %w{install-plugin -n test}
				result = @subj.parse( args )
				assert_equal PARSED_ARGS.merge( name: 'test' ), @subj.options
				assert_equal Jenkins2::CLI::InstallPlugin, result.class
			end

			def test_parse_global_arguments_with_2_word_command_separated_by_space
				args = @args + %w{install plugin -n test}
				result = @subj.parse( args )
				assert_equal PARSED_ARGS.merge( name: 'test' ), @subj.options
				assert_equal Jenkins2::CLI::InstallPlugin, result.class
			end

			def test_parse_global_arguments_with_2_word_command_and_command_arguments
				args = @args + %w{install-plugin -n thinBackup}
				result = @subj.parse( args )
				assert_equal PARSED_ARGS.merge( name: 'thinBackup' ), @subj.options
				assert_equal Jenkins2::CLI::InstallPlugin, result.class
			end

			def test_parse_command_arguments_before_command
				args = @args + %w{-s http://jenkins.com -n thinBackup install-plugin}
				exc = assert_raises OptionParser::InvalidOption do
					@subj.parse( args )
				end
				assert_equal 'invalid option: -n', exc.message
			end

			def test_parse_global_arguments_after_command_with_no_arguments
				args = %w{version} + @args
				exc = assert_raises OptionParser::InvalidOption do
					@subj.parse( args )
				end
				assert_equal 'invalid option: -s', exc.message
			end

			def test_parse_global_arguments_after_command_that_accepts_arguments
				args = %w{uninstall-plugin -s http://jenkins.com -n thinBackup}
				exc = assert_raises OptionParser::InvalidOption do
					@subj.parse( args )
				end
				assert_equal 'invalid option: -s', exc.message
			end

			def test_parse_verbose
				assert_equal 1, Jenkins2::CLI.new.parse( @args + %w{-v1} ).options[:verbose]
				assert_equal 2, Jenkins2::CLI.new.parse( @args + %w{-v2} ).options[:verbose]
				assert_equal 3, Jenkins2::CLI.new.parse( @args + %w{-v3} ).options[:verbose]
				assert_equal 2, Jenkins2::CLI.new.parse( @args + %w{-v 2} ).options[:verbose]
			end

			def test_run_no_commands
				assert_equal GLOBAL_SUMMARY + COMMANDS_SUMMARY, @subj.parse( @args ).call
			end

			def test_run_part_command
				assert_equal GLOBAL_SUMMARY + COMMANDS_SUMMARY, @subj.parse( @args + %w{install} ).call
			end

			def test_show_help_with_full_command
				assert_equal GLOBAL_SUMMARY + COMMAND_SUMMARY, @subj.
					parse( @args + %w{--help uninstall-plugin -n test} ).call
			end

			def test_show_help_with_full_command_missing_mandatory_arguments
				result = @subj.parse( %w{--help uninstall-plugin} )
				assert_equal ['Missing argument(s): server, name.'], result.errors
				assert_equal GLOBAL_SUMMARY + COMMAND_SUMMARY, result.call
			end

			def test_full_command_missing_mandatory_argument
				result = @subj.parse( @args + %w{uninstall-plugin} )
				assert_equal ['Missing argument(s): name.'], result.errors
				assert_equal result.errors.first + "\n" + GLOBAL_SUMMARY + COMMAND_SUMMARY, result.call
			end

			def test_read_config_file
				@subj.parse( @args + ['-c', @config_file.path] )
				assert_equal PARSED_ARGS.merge( verbose: '3', config: @config_file.path ), @subj.options
			end
		end
	end
end
