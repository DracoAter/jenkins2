# frozen_string_literal: true

module Jenkins2
	class API
		# Provides support for role-strategy plugin.
		# Allows creating, deleting, assigning, unassigning and listing roles.
		module RoleStrategy
			module RoleType
				GLOBAL = 'globalRoles'
				PROJECT = 'projectRoles'
				SLAVE = 'slaveRoles'
			end

			# Step into proxy for managing roles in role-strategy.
			# ==== Returns:
			# A proxy object that enables different operations on roles.
			def roles
				Proxy.new connection, 'role-strategy/strategy'
			end

			class Proxy < ::Jenkins2::ResourceProxy
				# Get existing roles and users assigned to them.
				# *Returns*:: Hash where keys are roles, and values are arrays of users assigned to role.
				def list
					::JSON.parse(connection.get(build_path('getAllRoles')).body,
						object_class: ::OpenStruct).to_h
				end

				# Create a role in role-strategy
				# ==== Parameters:
				# +role+:: Role name.
				# +type+:: Role type. Use RoleType enum values.
				# +permissions+:: Array of permission ids. Default is - no permissions.
				# +pattern+:: Slave or project pattern. Ignored for global roles.
				# ==== Returns:
				# True on success
				def create(role:, type:, permissions: [], pattern: nil)
					connection.post(build_path('addRole'), nil, roleName: role, type: type,
						permissionIds: (permissions || []).join(','), pattern: pattern, overwrite: false).
						code == '200'
				end

				# Delete role(s) in role-strategy
				# ==== Parameters:
				# +role+:: Role name or array of role names.
				# +type+:: Role type. Use RoleType enum values.
				# ==== Returns:
				# True on success
				def delete(role:, type:)
					connection.post(build_path('removeRoles'), nil, roleNames: [role].flatten.join(','),
						type: type).code == '200'
				end

				# Assign role to user in role-strategy
				# ==== Parameters:
				# +role+:: Role name.
				# +type+:: Role type. Use RoleType enum values.
				# +rsuser+:: Username.
				# ==== Returns:
				# True on success
				def assign(role:, type:, rsuser:)
					connection.post(build_path('assignRole'), nil, roleName: role, type: type, sid: rsuser).
						code == '200'
				end

				# Unassign role from user in role-strategy
				# ==== Parameters:
				# +role+:: Role name.
				# +type+:: Role type. Use RoleType enum values.
				# +rsuser+:: Username.
				# ==== Returns:
				# True on success
				def unassign(role:, type:, rsuser:)
					connection.post(build_path('unassignRole'), nil, roleName: role, type: type, sid: rsuser).
						code == '200'
				end

				# Unassign all roles from user in role-strategy
				# ==== Parameters:
				# +type+:: Role type. Use RoleType enum values.
				# +rsuser+:: Username.
				# ==== Returns:
				# True on success
				def unassign_all(type:, rsuser:)
					connection.post(build_path('deleteSid'), nil, type: type, sid: rsuser).code == '200'
				end
			end
		end
	end
end
