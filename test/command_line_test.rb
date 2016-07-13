require 'uri'
require 'mocha'
require_relative 'test_helper'

module Jenkins
	class CommandLineTest < Minitest::Test
		def test_options_in_right_order
			args = %w{-s http://jenkins.com online-node -n nodename}
			@subj = CommandLine.new( args )
			assert_equal( { :server => URI.parse( 'http://jenkins.com' ), :command => 'online-node' },
				@subj.global_options )
			assert_equal( { :node => 'nodename' }, @subj.command_options )
		end

		def test_command_options_before_command
			args = %w{-s http://jenkins.com -n nodename -m test offline-node}
			@subj = CommandLine.new( args )
			assert_equal( { :server => URI.parse( 'http://jenkins.com' ), :command => 'offline-node' },
				@subj.global_options )
			assert_equal( { :node => 'nodename', :message => 'test' }, @subj.command_options )
		end

		def test_global_options_after_command
			args = %w{online-node -s http://jenkins.com -n nodename}
			@subj = CommandLine.new( args )
			assert_equal( { :server => URI.parse( 'http://jenkins.com' ), :command => 'online-node' },
				@subj.global_options )
			assert_equal( { :node => 'nodename' }, @subj.command_options )
		end

		def test_read_config_file_if_provided
			IO.expects( :read ).with( 'myfile_jenkins.json' ).once.returns '{"user":"admin"}'
			args = %w{online-node -s http://jenkins.com -n nodename -c myfile_jenkins.json}
			@subj = CommandLine.new( args )
			assert_equal( { server: URI.parse( 'http://jenkins.com' ), command: 'online-node',
				user: 'admin', config_file: 'myfile_jenkins.json' }, @subj.global_options )
		end

		def test_read_default_config_file_if_no_path
			IO.expects( :read ).with( '~/.jenkins.json' ).once.returns '{"user":"admin"}'
			args = %w{online-node -s http://jenkins.com -n nodename -c}
			@subj = CommandLine.new( args )
			assert_equal( { server: URI.parse( 'http://jenkins.com' ), command: 'online-node',
				user: 'admin', config_file: '~/.jenkins.json' }, @subj.global_options )
		end

		def test_do_not_read_config_file_by_default
			IO.expects( :read ).with( '~/.jenkins.json' ).times( 0 ).returns '{"user":"admin"}'
			args = %w{online-node -s http://jenkins.com -n nodename}
			@subj = CommandLine.new( args )
			assert_equal( { server: URI.parse( 'http://jenkins.com' ), command: 'online-node' },
				@subj.global_options )
		end

		def test_no_command
			args = %w{-s http://jenkins.com -n nodename}
			Log.expects( :fatal ).twice
			assert_raises OptionParser::MissingArgument, SystemExit do CommandLine.new( args ) end
		end

		def test_wrong_command
			args = %w{-s http://jenkins.com no-such-command}
			Log.expects( :fatal ).twice
			assert_raises OptionParser::MissingArgument, SystemExit do CommandLine.new( args ) end
		end

		def test_unknown_option_and_wrong_command
			args = %w{-s http://jenkins.com -n nodename no-such-command}
			Log.expects( :fatal ).twice
			assert_raises OptionParser::InvalidOption, SystemExit do CommandLine.new( args ) end
		end

		def test_two_commands_second_ignored
			args = %w{-s http://jenkins.com -n nodename offline-node online-node}
			assert_equal( { :server => URI.parse( 'http://jenkins.com' ), :command => 'offline-node' },
				CommandLine.new( args ).global_options )
		end

		def test_help
			args = %w{--help}
			Log.expects( :unknown ).once
			assert_raises SystemExit do CommandLine.new( args ) end
		end

		def test_help_with_command
			args = %w{--help online-node}
			Log.expects( :unknown ).once
			assert_raises SystemExit do CommandLine.new( args ) end
		end

		def test_verbose
			args = %w{-v online-node}
			Log.expects( :init ).with( verbose: 1, log_file: STDOUT ).once
			CommandLine.new( args )

			args = %w{-vv online-node}
			Log.expects( :init ).with( verbose: 2, log_file: STDOUT ).once
			CommandLine.new( args )
		end
	end
end
