# frozen_string_literal: true

require_relative 'test_helper'

module Jenkins2
	module UnitTest
		class CLITest < Minitest::Test
			PARSED_ARGS = {
				server: ::URI.parse('http://jenkins.com'),
				user: 'admin',
				key: 'as213t2e'
			}.freeze

			GLOBAL_SUMMARY = %{Usage: jenkins2 [global-arguments] <command> [command-arguments]

Global arguments (accepted by all commands):
    -s, --server URL                 Jenkins Server Url
    -u, --user USER                  Jenkins API User
    -k, --key KEY                    Jenkins API Key
    -c, --config [PATH]              Read configuration file. All global options can be \
configured in configuration file. File format is yaml. Arguments provided in command line will \
overwrite those in configuration file. Program looks for .jenkins2.conf in current directory if \
no PATH is provided.
    -l, --log FILE                   Log file. Prints to standard out, if not provided
    -v, --verbose VALUE              Print more info. 1 up to 3. Prints only errors by default.
    -h, --help                       Show help
    -V, --version                    Show version

For command specific arguments run: jenkins2 --help <command>

}
			COMMANDS_SUMMARY = %{Commands:
    add-job-to-view                  Add jobs to view.
    assign-role                      Assign role to user in role-strategy plugin.
    cancel-quiet-down                Cancel previously issued quiet-down command.
    connect-node                     Reconnect node(s).
    copy-job                         Copy a job.
    create-credentials-by-xml        Create credential by reading stdin as an XML configuration.
    create-credentials-domain-by-xml Create credential domain by reading stdin as an XML \
configuration.
    create-job                       Create a new job by reading stdin as an XML configuration.
    create-node                      Create a new node by reading stdin for an XML configuration.
    create-role                      Create a role in role-strategy plugin.
    create-view                      Create a new view by reading stdin as an XML configuration.
    delete-credentials               Delete credentials.
    delete-credentials-domain        Delete credentials domain.
    delete-job                       Delete a job.
    delete-node                      Delete node(s).
    delete-roles                     Delete role(s) in role-strategy plugin.
    delete-view                      Delete view(s).
    disable-job                      Disable a job, restrict all builds of the job from now on.
    disconnect-node                  Disconnect node(s).
    enable-job                       Enable job, allow building the job. Cancels previously \
issued \"disable-job\".
    get-credentials-as-xml           Get a credential as XML (secrets redacted).
    get-credentials-domain-as-xml    Get credentials domain as XML.
    get-job                          Dump the job definition XML to stdout.
    get-node                         Dump the node definition XML to stdout.
    get-view                         Dump the view definition XML to stdout.
    install-plugin                   Install a plugin either from a file, an URL, standard \
input or from update center.
    list-credentials                 List credentials in a specific store.
    list-jobs                        List all jobs in a specific view or item group.
    list-node                        Output the node list.
    list-online-node                 Output the online node list.
    list-plugins                     List all installed plugins.
    list-roles                       List all global roles in role-strategy plugin.
    offline-node                     Stop using a node for performing builds temporarily, until \
the next "online-node" command.
    online-node                      Resume using a node for performing builds, to cancel out \
the earlier "offline-node" command.
    quiet-down                       Put Jenkins into the quiet mode, wait for existing builds \
to be completed.
    remove-job-from-view             Remove jobs from view.
    restart                          Restart Jenkins.
    safe-restart                     Safely restart Jenkins.
    show-plugin                      Show plugin info.
    unassign-all-roles               Unassign all roles from user in role-strategy plugin.
    unassign-role                    Unassign role from user in role-strategy plugin.
    uninstall-plugin                 Uninstall a plugin.
    update-credentials-by-xml        Update credentials by XML.
    update-credentials-domain-by-xml Update credentials domain by XML.
    update-job                       Update the job definition XML from stdin. The opposite of \
the \"get-job\" command.
    update-node                      Update the node definition XML from stdin. The opposite of \
the get-node command.
    update-view                      Update the view definition XML from stdin. The opposite of \
the get-view command.
    version                          Jenkins version.
    wait-node-offline                Wait for a node to become offline.
    wait-node-online                 Wait for a node to become online.
    who-am-i                         Report your credentials.
}

			COMMAND_SUMMARY = %{Command:
    uninstall-plugin                 Uninstall a plugin.
Mandatory arguments:
    -n, --name SHORTNAME             Plugin short name (like thinBackup).
}

			def setup
				@subj = Jenkins2::CLI.new
				@config_file = Tempfile.open('jenkins2.conf') do |f|
					f.write(<<~YAML
						---
						:user: fromconfigfile
						:verbose: 3
					YAML
					)
					f
				end
				@args = %w[-s http://jenkins.com -k as213t2e --user admin]
			end

			def teardown
    #				@config_file.unlink
			end

			def test_parse_arguments_mandatory_missing
				assert_equal ['Missing argument(s): server.'], @subj.parse([]).errors
			end

			def test_parse_global_arguments
				result = @subj.parse @args
				assert_equal PARSED_ARGS, @subj.options
				assert_equal Jenkins2::CLI, result.class
			end

			def test_parse_global_arguments_with_command
				args = @args + %w[restart]
				result = @subj.parse(args)
				assert_equal PARSED_ARGS, @subj.options
				assert_equal Jenkins2::CLI::Restart, result.class
			end

			def test_parse_global_arguments_with_2_word_command
				args = @args + %w[install-plugin -n test]
				result = @subj.parse(args)
				assert_equal PARSED_ARGS, @subj.options
				assert_equal PARSED_ARGS.merge(name: 'test'), result.options
				assert_equal Jenkins2::CLI::InstallPlugin, result.class
			end

			def test_parse_global_arguments_with_2_word_command_separated_by_space
				args = @args + %w[install plugin -n test]
				result = @subj.parse(args)
				assert_equal PARSED_ARGS, @subj.options
				assert_equal PARSED_ARGS.merge(name: 'test'), result.options
				assert_equal Jenkins2::CLI::InstallPlugin, result.class
			end

			def test_parse_global_arguments_with_2_word_command_and_command_arguments
				args = @args + %w[install-plugin -n thinBackup]
				result = @subj.parse(args)
				assert_equal PARSED_ARGS, @subj.options
				assert_equal PARSED_ARGS.merge(name: 'thinBackup'), result.options
				assert_equal Jenkins2::CLI::InstallPlugin, result.class
			end

			def test_parse_command_arguments_before_command
				args = @args + %w[-s http://jenkins.com -n thinBackup install-plugin]
				exc = assert_raises OptionParser::InvalidOption do
					@subj.parse(args)
				end
				assert_equal 'invalid option: -n', exc.message
			end

			def test_parse_global_arguments_after_command_with_no_arguments
				args = %w[version] + @args
				exc = assert_raises OptionParser::InvalidOption do
					@subj.parse(args)
				end
				assert_equal 'invalid option: -s', exc.message
			end

			def test_parse_global_arguments_after_command_that_accepts_arguments
				args = %w[uninstall-plugin -s http://jenkins.com -n thinBackup]
				exc = assert_raises OptionParser::InvalidOption do
					@subj.parse(args)
				end
				assert_equal 'invalid option: -s', exc.message
			end

			def test_parse_verbose
				assert_equal 1, Jenkins2::CLI.new.parse(@args + %w[-v1]).options[:verbose]
				assert_equal 2, Jenkins2::CLI.new.parse(@args + %w[-v2]).options[:verbose]
				assert_equal 3, Jenkins2::CLI.new.parse(@args + %w[-v3]).options[:verbose]
				assert_equal 2, Jenkins2::CLI.new.parse(@args + %w[-v 2]).options[:verbose]
			end

			def test_run_no_commands
				assert_equal GLOBAL_SUMMARY + COMMANDS_SUMMARY, @subj.parse(@args).call
			end

			def test_run_part_command
				assert_equal GLOBAL_SUMMARY + COMMANDS_SUMMARY, @subj.parse(@args + %w[install]).call
			end

			def test_show_help_with_full_command
				assert_equal GLOBAL_SUMMARY + COMMAND_SUMMARY, @subj.
					parse(@args + %w[--help uninstall-plugin -n test]).call
			end

			def test_show_help_with_full_command_missing_mandatory_arguments
				result = @subj.parse(%w[--help uninstall-plugin])
				assert_equal ['Missing argument(s): server, name.'], result.errors
				assert_equal GLOBAL_SUMMARY + COMMAND_SUMMARY, result.call
			end

			def test_full_command_missing_mandatory_argument
				result = @subj.parse(@args + %w[uninstall-plugin])
				assert_equal ['Missing argument(s): name.'], result.errors
				assert_equal result.errors.first + "\n" + GLOBAL_SUMMARY + COMMAND_SUMMARY, result.call
			end

			def test_read_config_file
				@subj.parse(@args + ['-c', @config_file.path])
				assert_equal PARSED_ARGS.merge(verbose: 3, config: @config_file.path), @subj.options
			end

			def test_gem_version
				assert_equal Jenkins2::VERSION, Jenkins2::CLI.new.parse(%w[-V]).call
			end
		end
	end
end
