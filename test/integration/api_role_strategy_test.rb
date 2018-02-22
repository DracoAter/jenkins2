# frozen_string_literal: true

require_relative 'test_helper'

module Jenkins2
	module IntegrationTest
		class ApiRoleStrategyTest < Minitest::Test
			def test_get
				assert_equal ['admin'], @@subj.roles.list[:admin]
			end

			def test_create_delete_global
				assert_equal true, @@subj.roles.create(role: 'authenticated',
					type: Jenkins2::API::RoleStrategy::RoleType::GLOBAL,
					permissions: %w[hudson.model.Hudson.Read hudson.model.Item.Discover])
				assert_equal [], @@subj.roles.list[:authenticated]
				assert_equal true, @@subj.roles.delete(role: 'authenticated',
					type: Jenkins2::API::RoleStrategy::RoleType::GLOBAL)
				assert_nil @@subj.roles.list[:authenticated]
			end

			def test_create_delete_project
				assert_equal true, @@subj.roles.create(role: 'test', pattern: 'test.*',
					type: Jenkins2::API::RoleStrategy::RoleType::PROJECT,
					permissions: %w[hudson.model.Hudson.Read hudson.model.Item.Discover],
				)
				# TODO: Find how to list project roles
				# assert_equal [], @@subj.roles.list[:test]
				assert_equal true, @@subj.roles.delete(role: 'test',
					type: Jenkins2::API::RoleStrategy::RoleType::PROJECT)
				# TODO: Find how to list project roles
				# assert_nil @@subj.roles.list[:test]
			end

			def test_assign_unassign_global
				assert_nil @@subj.roles.list[:test]
				@@subj.roles.create(role: 'test', type: Jenkins2::API::RoleStrategy::RoleType::GLOBAL)
				assert_equal true, @@subj.roles.assign(role: 'test', rsuser: 'random',
					type: Jenkins2::API::RoleStrategy::RoleType::GLOBAL)
				assert_equal ['random'], @@subj.roles.list[:test]
				assert_equal true, @@subj.roles.unassign(role: 'test', rsuser: 'random',
					type: Jenkins2::API::RoleStrategy::RoleType::GLOBAL)
				assert_equal [], @@subj.roles.list[:test]
			ensure
				@@subj.roles.delete(role: 'test', type: Jenkins2::API::RoleStrategy::RoleType::GLOBAL)
			end

			def test_unassign_all
				assert_nil @@subj.roles.list[:test]
				@@subj.roles.create(role: 'test', type: Jenkins2::API::RoleStrategy::RoleType::GLOBAL)
				@@subj.roles.create(role: 'test2', type: Jenkins2::API::RoleStrategy::RoleType::GLOBAL)
				@@subj.roles.assign(role: 'test', rsuser: 'random',
					type: Jenkins2::API::RoleStrategy::RoleType::GLOBAL)
				@@subj.roles.assign(role: 'test2', rsuser: 'random',
					type: Jenkins2::API::RoleStrategy::RoleType::GLOBAL)
				assert_equal ['random'], @@subj.roles.list[:test]
				assert_equal ['random'], @@subj.roles.list[:test2]
				assert_equal true, @@subj.roles.unassign_all(rsuser: 'random',
					type: Jenkins2::API::RoleStrategy::RoleType::GLOBAL)
				assert_equal [], @@subj.roles.list[:test]
				assert_equal [], @@subj.roles.list[:test2]
			ensure
				@@subj.roles.delete(role: 'test', type: Jenkins2::API::RoleStrategy::RoleType::GLOBAL)
				@@subj.roles.delete(role: 'test2', type: Jenkins2::API::RoleStrategy::RoleType::GLOBAL)
			end
		end
	end
end
