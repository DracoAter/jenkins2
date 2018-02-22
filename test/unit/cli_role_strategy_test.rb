# frozen_string_literal: true

require_relative 'test_helper'

module Jenkins2
	module UnitTest
		class CliRoleStrategyTest < Minitest::Test
			def test_list_roles_summary
				assert_equal Jenkins2::UnitTest::CLITest::GLOBAL_SUMMARY +
					%(Command:
    list-roles                       List all global roles in role-strategy plugin.
), Jenkins2::CLI::ListRoles.new.send(:summary)
			end

			def test_create_role_summary
				assert_equal Jenkins2::UnitTest::CLITest::GLOBAL_SUMMARY +
					%(Command:
    create-role                      Create a role in role-strategy plugin.
Mandatory arguments:
        --role ROLE                  Role name.
        --type TYPE                  Role type. One of: globalRoles, projectRoles, slaveRoles.
Optional arguments:
        --permissions X,Y,..         Comma-separated list of permissions.
        --pattern PATTERN            Slave or project pattern. Ignored for global roles.
), Jenkins2::CLI::CreateRole.new.send(:summary)
			end

			def test_delete_roles_summary
				assert_equal Jenkins2::UnitTest::CLITest::GLOBAL_SUMMARY +
					%(Command:
    delete-roles                     Delete role(s) in role-strategy plugin.
Mandatory arguments:
        --role X,Y,..                Role names.
        --type TYPE                  Role type. One of: globalRoles, projectRoles, slaveRoles.
), Jenkins2::CLI::DeleteRoles.new.send(:summary)
			end

			def test_assign_role_summary
				assert_equal Jenkins2::UnitTest::CLITest::GLOBAL_SUMMARY +
					%(Command:
    assign-role                      Assign role to user in role-strategy plugin.
Mandatory arguments:
        --role ROLE                  Role name.
        --type TYPE                  Role type. One of: globalRoles, projectRoles, slaveRoles.
        --rsuser USER                Username.
), Jenkins2::CLI::AssignRole.new.send(:summary)
			end

			def test_unassign_role_summary
				assert_equal Jenkins2::UnitTest::CLITest::GLOBAL_SUMMARY +
					%(Command:
    unassign-role                    Unassign role from user in role-strategy plugin.
Mandatory arguments:
        --role ROLE                  Role name.
        --type TYPE                  Role type. One of: globalRoles, projectRoles, slaveRoles.
        --rsuser USER                Username.
), Jenkins2::CLI::UnassignRole.new.send(:summary)
			end

			def test_assign_all_roles_summary
				assert_equal Jenkins2::UnitTest::CLITest::GLOBAL_SUMMARY +
					%(Command:
    unassign-all-roles               Unassign all roles from user in role-strategy plugin.
Mandatory arguments:
        --type TYPE                  Role type. One of: globalRoles, projectRoles, slaveRoles.
        --rsuser USER                Username.
), Jenkins2::CLI::UnassignAllRoles.new.send(:summary)
			end
		end
	end
end
