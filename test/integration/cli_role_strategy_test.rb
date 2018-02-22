# frozen_string_literal: true

require_relative 'test_helper'

module Jenkins2
	module IntegrationTest
		class CliRoleStrategyTest < Minitest::Test
			def test_list_roles
				assert_includes Jenkins2::CLI::ListRoles.new(@@opts).call, "admin: admin"
			end

			def test_create_delete_global_role
				assert_equal true, Jenkins2::CLI::CreateRole.new(@@opts).parse(
					['--role', 'cli_test', '--type', 'globalRoles', '--permissions',
					'hudson.model.Hudson.Read,hudson.model.Item.Discover']
				).call
				assert_equal [], @@subj.roles.list[:cli_test]
				assert_equal true, Jenkins2::CLI::DeleteRoles.new(@@opts).parse(
					['--role', 'cli_test', '--type', 'globalRoles']
				).call
				assert_nil @@subj.roles.list[:cli_test]
			end

			def test_create_delete_project_role
				assert_equal true, Jenkins2::CLI::CreateRole.new(@@opts).parse(
					['--role', 'clitest', '--type', 'projectRoles', '--pattern', 'test.*', '--permissions',
					'hudson.model.Hudson.Read,hudson.model.Item.Discover']
				).call
				# TODO: Find how to list project roles
				# assert_equal [], @@subj.roles.list[:test]
				assert_equal true, Jenkins2::CLI::DeleteRoles.new(@@opts).parse(
					['--role', 'clitest', '--type', 'projectRoles']
				).call
				# TODO: Find how to list project roles
				# assert_nil @@subj.roles.list[:test]
			end

			def test_assign_unassign_global_role
				assert_nil @@subj.roles.list[:cli_test1]
				Jenkins2::CLI::CreateRole.new(@@opts).parse(
					['--role', 'cli_test1', '--type', 'globalRoles']
				).call
				assert_equal true, Jenkins2::CLI::AssignRole.new(@@opts).parse(
					['--role', 'cli_test1', '--type', 'globalRoles', '--rsuser', 'cli_random']
				).call
				assert_equal ['cli_random'], @@subj.roles.list[:cli_test1]
				assert_equal true, Jenkins2::CLI::UnassignRole.new(@@opts).parse(
					['--role', 'cli_test1', '--type', 'globalRoles', '--rsuser', 'cli_random']
				).call
				assert_equal [], @@subj.roles.list[:cli_test1]
			ensure
				@@subj.roles.delete(role: 'cli_test1', type: Jenkins2::API::RoleStrategy::RoleType::GLOBAL)
			end

			def test_unassign_all_roles
				assert_nil @@subj.roles.list[:cli_test2]
				Jenkins2::CLI::CreateRole.new(@@opts).parse(
					['--role', 'cli_test2', '--type', 'globalRoles']
				).call
				Jenkins2::CLI::CreateRole.new(@@opts).parse(
					['--role', 'cli_test3', '--type', 'globalRoles']
				).call
				Jenkins2::CLI::AssignRole.new(@@opts).parse(
					['--role', 'cli_test2', '--type', 'globalRoles', '--rsuser', 'cli_random1']
				).call
				Jenkins2::CLI::AssignRole.new(@@opts).parse(
					['--role', 'cli_test3', '--type', 'globalRoles', '--rsuser', 'cli_random1']
				).call
				assert_equal ['cli_random1'], @@subj.roles.list[:cli_test2]
				assert_equal ['cli_random1'], @@subj.roles.list[:cli_test3]
				assert_equal true, Jenkins2::CLI::UnassignAllRoles.new(@@opts).parse(
					['--type', 'globalRoles', '--rsuser', 'cli_random1']
				).call
				assert_equal [], @@subj.roles.list[:cli_test2]
				assert_equal [], @@subj.roles.list[:cli_test3]
			ensure
				@@subj.roles.delete(role: 'cli_test2', type: Jenkins2::API::RoleStrategy::RoleType::GLOBAL)
				@@subj.roles.delete(role: 'cli_test3', type: Jenkins2::API::RoleStrategy::RoleType::GLOBAL)
			end
		end
	end
end
