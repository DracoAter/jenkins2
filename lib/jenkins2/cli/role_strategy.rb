# frozen_string_literal: true

module Jenkins2
	class CLI
		# Provides list-roles command in CLI. Requires role-strategy plugin enabled.
		class ListRoles < CLI
			def self.description
				'List all global roles in role-strategy plugin.'
			end

			def run
				jc.roles.list.collect do |role, users|
					"#{role}: #{users.join(',')}"
				end.join("\n")
			end
		end

		# Provides create-role command in CLI. Requires role-strategy plugin enabled.
		class CreateRole < CLI
			def self.description
				'Create a role in role-strategy plugin.'
			end

			def add_options
				parser.separator 'Mandatory arguments:'
				parser.on '--role ROLE', 'Role name.' do |r|
					options[:role] = r
				end
				parser.on '--type TYPE', 'Role type. One of: globalRoles, projectRoles, slaveRoles.' do |t|
					options[:type] = t
				end
				parser.separator 'Optional arguments:'
				parser.on '--permissions X,Y,..', Array, 'Comma-separated list of permissions.' do |p|
					options[:permissions] = p
				end
				parser.on '--pattern PATTERN', 'Slave or project pattern. Ignored for global roles.' do |p|
					options[:pattern] = p
				end
			end

			def mandatory_arguments
				super + %i[role type]
			end

			def run
				jc.roles.create(role: options[:role], type: options[:type],
					permissions: options[:permissions], pattern: options[:pattern])
			end
		end

		# Provides delete-role command in CLI. Requires role-strategy plugin enabled.
		class DeleteRoles < CLI
			def self.description
				'Delete role(s) in role-strategy plugin.'
			end

			def add_options
				parser.separator 'Mandatory arguments:'
				parser.on '--role X,Y,..', Array, 'Role names.' do |r|
					options[:role] = r
				end
				parser.on '--type TYPE', 'Role type. One of: globalRoles, projectRoles, slaveRoles.' do |t|
					options[:type] = t
				end
			end

			def mandatory_arguments
				super + %i[role type]
			end

			def run
				jc.roles.delete(role: options[:role], type: options[:type])
			end
		end

		# Provides assign-role command in CLI. Requires role-strategy plugin enabled.
		class AssignRole < CLI
			def self.description
				'Assign role to user in role-strategy plugin.'
			end

			def add_options
				parser.separator 'Mandatory arguments:'
				parser.on '--role ROLE', 'Role name.' do |r|
					options[:role] = r
				end
				parser.on '--type TYPE', 'Role type. One of: globalRoles, projectRoles, slaveRoles.' do |t|
					options[:type] = t
				end
				parser.on '--rsuser USER', 'Username.' do |u|
					options[:rsuser] = u
				end
			end

			def mandatory_arguments
				super + %i[role type rsuser]
			end

			def run
				jc.roles.assign(role: options[:role], type: options[:type], rsuser: options[:rsuser])
			end
		end

		# Provides unassign-role command in CLI. Requires role-strategy plugin enabled.
		class UnassignRole < CLI
			def self.description
				'Unassign role from user in role-strategy plugin.'
			end

			def add_options
				parser.separator 'Mandatory arguments:'
				parser.on '--role ROLE', 'Role name.' do |r|
					options[:role] = r
				end
				parser.on '--type TYPE', 'Role type. One of: globalRoles, projectRoles, slaveRoles.' do |t|
					options[:type] = t
				end
				parser.on '--rsuser USER', 'Username.' do |u|
					options[:rsuser] = u
				end
			end

			def mandatory_arguments
				super + %i[role type rsuser]
			end

			def run
				jc.roles.unassign(role: options[:role], type: options[:type], rsuser: options[:rsuser])
			end
		end

		# Provides unassign-all-roles command in CLI. Requires role-strategy plugin enabled.
		class UnassignAllRoles < CLI
			def self.description
				'Unassign all roles from user in role-strategy plugin.'
			end

			def add_options
				parser.separator 'Mandatory arguments:'
				parser.on '--type TYPE', 'Role type. One of: globalRoles, projectRoles, slaveRoles.' do |t|
					options[:type] = t
				end
				parser.on '--rsuser USER', 'Username.' do |u|
					options[:rsuser] = u
				end
			end

			def mandatory_arguments
				super + %i[type rsuser]
			end

			def run
				jc.roles.unassign_all(type: options[:type], rsuser: options[:rsuser])
			end
		end
	end
end
